#- prologue --------------------------------------------------------------------
use nqp;  # Hopefully will be in core at some point

my enum Status is export <OK MORE-INPUT CONTROL>;

#- CodeUnit --------------------------------------------------------------------
class CodeUnit:ver<0.0.3>:auth<zef:lizmat> {

    # The low level compiler to be used
    has Mu $.compiler is built(:bind) = "Raku";

    # The current NQP context that has all of the definitions that were
    # made in this session
    has Mu $.context is built(:bind) = nqp::null;
    has Mu $!reset-context;

    # Whether it is allowed to have code evalled stretching over
    # multiple lines
    has Bool $.multi-line-ok is rw = !%*ENV<RAKUDO_DISABLE_MULTILINE>;

    # Return state from evaluation
    has Status $.state is rw is built(False) = OK;

    # Any exception that should be reported
    has Mu $.exception is rw is built(False);

    method TWEAK() {
        $!compiler := nqp::getcomp(nqp::decont($!compiler))
          if nqp::istype($!compiler,Str);

        $!context       := nqp::decont($!context);
        $!reset-context := $!context;
    }

    method eval(str $code) {
        CATCH {
            when X::Syntax::Missing | X::Comp::FailGoal {
                if $!multi-line-ok && .pos == $code.chars {
                    $!state = MORE-INPUT;
                    return Nil;
                }
                .throw
            }

            when X::AdHoc {
                if .message eq 'Premature heredoc consumption'
                  || .message.starts-with('Ending delimiter ') {
                    if $!multi-line-ok {
                        $!state = MORE-INPUT;
                        return Nil;
                    }
                }
                .throw
            }

            when X::ControlFlow::Return {
                $!exception = CX::Return;
                $!state     = CONTROL;
                return Nil;
            }

            when X::Syntax::InfixInTermPosition {
                if .infix eq "=" && $code.starts-with("=") {
                    say "Unknown REPL command: $code.words.head()";
                    say "Enter '=help' for a list of available REPL commands.";
                }
                else {
                    $!exception = $_;
                }
                return Nil;
            }

            default {
                $!exception = $_;
                return Nil;
            }
        }

        CONTROL {
            when CX::Emit | CX::Take {
                .rethrow;
            }
            when CX::Warn {
                .gist.say;
                .resume;
            }
            default {
                $!exception = $_;
                $!state     = CONTROL;
                return Nil;
            }
        }

        # Performe the actual evaluation magic
        my $*CTXSAVE  := self;
        my $*MAIN_CTX := $!context;
        my $value := do {
            $!compiler.eval(
              $code,
              :outer_ctx($!context),
              :interactive(1),
              |%_
            );
        }

        # Save the context state for the next evaluation
        $!state    = OK;
        $!context := $*MAIN_CTX;

        $value
    }

    # This appears to be a magic method that is called somewhere inside
    # the compiler.  The semantics of $*MAIN_CTX and $*CTXSAVE appear
    # to be needed to get a persistency with regards to scope between
    # calls to "eval".
    method ctxsave(--> Nil) is implementation-detail {
        $*MAIN_CTX := nqp::ctxcaller(nqp::ctx);
        $*CTXSAVE  := 0;
    }

    method reset(--> Nil) {
        $!context := $!reset-context;
    }

    method compiler-version(:$no-unicode --> Str:D) {
        $!compiler.version_string(:shorten-versions, :$no-unicode) ~ "\n"
    }

    # Provide completions
    method context-completions(&mapper = &ok-for-completion) {
        my $buffer := nqp::create(IterationBuffer);

        $!compiler.eval('CORE::.keys', :outer_ctx($!context))
          .map(&mapper).iterator.push-all($buffer);

        my $iterator := nqp::iterator(nqp::ctxlexpad($!context));
        nqp::while(
          $iterator,
          nqp::unless(
            nqp::istype(
              nqp::iterval(nqp::shift($iterator)),
              Rakudo::Internals::LoweredAwayLexical
            ),
            nqp::push($buffer, nqp::iterkey_s($iterator))
          )
        );

        my $PACKAGE := $!compiler.eval('$?PACKAGE', :outer_ctx($!context));
        $PACKAGE.WHO.keys.map(&mapper).iterator.push-all($buffer);

        $buffer.List
    }
}

#- helper subs -----------------------------------------------------------------

# Is word long enough?
my sub long-enough($_) { .chars > 1 ?? $_ !! Empty }

# Is a word ok to be included in completions
my sub ok-for-completion($_) {
    .contains(/ <.lower> /)
      ?? .starts-with('&')
        ?? .contains("fix:" | "mod:")
          ?? Empty            # don't bother with operators and traits
          !! long-enough(.substr(1))
        !! .contains(/ \W /)
          ?? Empty            # don't bother with non-sub specials
          !! long-enough($_)
      !! Empty                # don't bother will all uppercase
}

#- exported subs ---------------------------------------------------------------

my sub context(--> Mu) is export {
    nqp::ctxcaller(nqp::ctx)
}

# vim: expandtab shiftwidth=4

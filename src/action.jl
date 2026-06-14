
abstract type AbstractAction end
struct KillAction <: AbstractAction end
struct TestAction <: AbstractAction end
struct GetSizeAction <: AbstractAction end
struct EchoAction <: AbstractAction end
struct RunScriptAction <: AbstractAction end

is_collective_action(::AbstractAction) = false
is_collective_action(::KillAction) = true
is_collective_action(::TestAction) = false
is_collective_action(::GetSizeAction) = false
is_collective_action(::EchoAction) = false
is_collective_action(::RunScriptAction) = true

"""
We could be tempted to use `Base.eval` here, but it can introduce injection vulnerability
(although on the server type dispatch is used so the risk is not high)
"""
function string_to_action(s)
    if s == "kill"
        return KillAction()
    elseif s == "test"
        return TestAction()
    elseif s == "getsize"
        return GetSizeAction()
    elseif s == "echo"
        return EchoAction()
    elseif s == "runscript"
        return RunScriptAction()
    end
end

action_to_string(a) = lowercase(string(nameof(typeof(a))))[1:end-length("action")]
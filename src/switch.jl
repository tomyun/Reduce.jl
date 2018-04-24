#   This file is part of Reduce.jl. It is licensed under the MIT license
#   Copyright (C) 2017 Michael Reed

const switchbas = [
    :expand,
    :complex,
    :div
]

const switches = [
    :factor,
    :ifactor,
    :expandlog,
    :combinelog,
    :precise,
    :combineexpt,
    :rounded,
    :evallhseq,
    :horner,
    :trigform,
    :fullroots,
    :cramer,
    :multiplicities,
    :allbranch,
    :arbvars,
    :solvesingular,
    :varopt,
    :intstr,
    :allfac,
    :rat,
    :revpri,
    :fort,
    :ratarg,
    :lcm,
    :gcd,
    :ezgcd,
    :heugcd,
    :bezout,
    :modular,
    :rational,
    :roundbf,
    :adjprec,
    :roundall,
    :balancedmod
]

const switchtex = [
    :nat,
    :latex
]

const onswitch = Symbol.("@",[switchbas;switches])
const offswitch = Symbol.("@off_",[switchbas;switches])

Expr(:toplevel,[:(import Base: $i) for i ∈ switchbas]...) |> eval
:(export $([switchbas;switches;switchtex]...)) |> eval
:(export $([onswitch;offswitch;Symbol.("@",switchtex)]...)) |> eval

for fun in [switchbas;switches;switchtex]
    @eval begin
        $(parsegen(fun,:switch))
        $fun(s::Bool) = (rcall("$(s ? "on" : "off") "*$(string(fun))); s)
    end
end

for fun in [switchbas;switches]
    @eval begin
        $(unfoldgen(fun,:switch))
        function $fun(expr::Compat.String;be=0)
            convert(Compat.String, $fun(RExpr(expr);be=be))
        end
    end
end

for fun in switchtex
    @eval begin
        $(unfoldgen(fun,:switch))
        function $fun(expr::Compat.String;be=0)
            convert(String, $fun(RExpr(expr);be=be))
        end
        macro $fun(expr)
            $fun(expr)
        end
    end
end

for fun in [switchbas;switches]
    @eval begin
        macro $fun(expr)
            (r,on,off) = macroshift(expr)
            push!(on,$(string(fun)))
            Expr(:quote,rcall(r;on=on,off=off))
        end
        macro $(Symbol("off_",fun))(expr)
            (r,on,off) = macroshift(expr)
            push!(off,$(string(fun)))
            Expr(:quote,rcall(r;on=on,off=off))
        end
    end
end

function macroshift(r)
    if typeof(r) == Expr && r.head == :macrocall
        (expr,on,off) = macroshift(r.args[2])
        if r.args[1] ∈ onswitch
            (expr,push!(on,string(r.args[1])[2:end]),off)
        elseif r.args[1] ∈ offswitch
            (expr,on,push!(off,string(r.args[1])[5:end]))
        else
            (eval(r),String[],String[])
        end
    else
        ((typeof(r)==Expr && r.head==:quote) ? r.args[1] : r,String[],String[])
    end
end
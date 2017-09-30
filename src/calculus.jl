#   This file is part of Reduce.jl. It is licensed under the MIT license
#   Copyright (C) 2017 Michael Reed

calculus = Symbol[
    :df,
    :int
]

:(export $(calculus...)) |> eval

for fun in calculus
    parsegen(fun,:calculus) |> eval
end

for fun in calculus
    quote
        function $fun(expr::Compat.String,s::Compat.String;be=0)
            convert(Compat.String, $fun(RExpr(expr),RExpr(s);be=be))
        end
        function $fun(expr::Expr,s;be=0)
            convert(Expr, $fun(RExpr(expr),RExpr(s);be=be))
        end
    end |> eval
end

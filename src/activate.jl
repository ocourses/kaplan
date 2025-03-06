using Suppressor
@suppress begin
    using Pkg
    Pkg.activate("/Users/ocots/Courses/edo/EDO_Interpolation_CPP/cours/src/")
    Pkg.instantiate()
    include("../assets/julia/myshow.jl")
    using Markdown
    using LaTeXStrings
    using QuizQuestions
end
nothing
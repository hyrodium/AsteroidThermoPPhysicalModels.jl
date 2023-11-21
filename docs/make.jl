using AsteroidThermoPPhysicalModels
using Documenter

DocMeta.setdocmeta!(AsteroidThermoPPhysicalModels, :DocTestSetup, :(using AsteroidThermoPPhysicalModels); recursive=true)

makedocs(;
    modules=[AsteroidThermoPPhysicalModels],
    repo="https://github.com/hyrodium/AsteroidThermoPPhysicalModels.jl/blob/{commit}{path}#{line}",
    sitename="AsteroidThermoPPhysicalModels.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://hyrodium.github.io/AsteroidThermoPPhysicalModels.jl",
        assets=["assets/favicon.ico"],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/hyrodium/AsteroidThermoPPhysicalModels.jl",
)

using AsteroidThermoPhysicalModels
using Documenter

DocMeta.setdocmeta!(AsteroidThermoPhysicalModels, :DocTestSetup, :(using AsteroidThermoPhysicalModels); recursive=true)

makedocs(;
    modules=[AsteroidThermoPhysicalModels],
    repo="https://github.com/hyrodium/AsteroidThermoPhysicalModels.jl/blob/{commit}{path}#{line}",
    sitename="AsteroidThermoPhysicalModels.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://hyrodium.github.io/AsteroidThermoPhysicalModels.jl",
        assets=["assets/favicon.ico"],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/hyrodium/AsteroidThermoPhysicalModels.jl",
)

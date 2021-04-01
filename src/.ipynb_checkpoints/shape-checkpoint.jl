
using LinearAlgebra


include("obj.jl")
include("smesh.jl")


struct Shape
    num_node::Int64
    num_face::Int64
    nodes::Vector{SVector{3,Float64}}
    faces::Vector{SVector{3,Int64}}

    smeshes::Vector{SMesh}

    AREA::Float64              # surface area
    VOLUME::Float64            # volume
    COF::SVector{3,Float64}    # center-of-figure
    I::SMatrix{3,3,Float64,9}  # moment of inertia tensor
end


function Base.show(io::IO, shape::Shape)
    println(io, "Shape model")
    println(io, "-----------")

    println("Nodes            : ", shape.num_node)
    println("Faces            : ", shape.num_face)
    println("Surface area     : ", shape.AREA)
    println("Volume           : ", shape.VOLUME)
    println("Center-of-Figure : ", shape.COF)
    println("Inertia tensor   : ")
    println("    | Ixx Ixy Ixz |   ", shape.I[1, :])
    println("    | Iyx Iyy Iyz | = ", shape.I[2, :])
    println("    | Izx Izy Izz |   ", shape.I[3, :])
end


function setShapeModel(shapepath::AbstractString; scale=1)
    nodes, faces = loadobj(shapepath; scale=scale, static=true, message=false)

    num_node = length(nodes)
    num_face = length(faces)
    
    smeshes = getmeshes(nodes, faces)

    AREA = sum(getareas(smeshes))
    VOLUME = getvolume(smeshes)
    COF = getCOF(smeshes)
    I = getMOI(smeshes)

    Shape(num_node, num_face, nodes, faces, smeshes, AREA, VOLUME, COF, I)
end


getFaceCenters(shape::Shape) = getcenters(shape.smeshes)
getFaceNormals(shape::Shape) = getnormals(shape.smeshes)
getFaceAreas(shape::Shape) = getareas(shape.smeshes)

findVisibleFaces!(shape::Shape) = findVisibleFaces!(shape.smeshes)


################################################################
#                      Shape properites
################################################################


"""
Calculate volume of a polyhedral
"""
getvolume(smeshes) = sum((((m.A × m.B) ⋅ m.C) / 6 for m in smeshes))


"""
Calculate center-of-figure of a polyhedral
"""
function getCOF(smeshes)
    VOLUME = getvolume(smeshes)
    COF = zeros(3)

    for m in smeshes
        volume = ((m.A × m.B) ⋅ m.C) / 6  # volume of pyramid element O-A-B-C
        center = (m.A + m.B + m.C) / 4    # center of pyramid element O-A-B-C
        COF += volume * center
    end
    COF / VOLUME
end


"""
Calculate moment of inertia of a polyhedron
"""
function getMOI(smeshes)
    I = zeros(3, 3)

    for m in smeshes
        # v1, v2, v3 = m.vs
        
        # I[3, 3] += (v1[1]*v1[1] + v1[1]*v2[1] + v2[1]*v2[1] + v1[1]*v3[1] + v2[1]*v3[1] + v3[1]*v3[1] + v1[2]*v1[2] + v1[2]*v2[2] + v2[2]*v2[2] + v1[2]*v3[2] + v2[2]*v3[2] + v3[2]*v3[2]) / 60

    end
    I
end


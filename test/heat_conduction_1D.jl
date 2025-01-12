
@testset "heat_conduction_1D" begin
    msg = """\n
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    |                Test: heat_conduction_1D                |
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
    """
    println(msg)

    ##= Shape model =##
    path_obj = joinpath("shape", "single_face.obj")
    shape = AsteroidThermoPPhysicalModels.load_shape_obj(path_obj)

    ##= Seeting of time step =##
    et_begin = 0.0
    et_end   = 1.0
    step     = 0.4e-4
    et_range = et_begin : step : et_end

    ephem = (
        time = collect(et_range),
    )

    ##= Thermal properties =##
    P  = 1.0
    k  = 1.0
    ρ  = 1.0
    Cₚ = 1.0
    
    l = AsteroidThermoPPhysicalModels.thermal_skin_depth(P, k, ρ, Cₚ)
    Γ = AsteroidThermoPPhysicalModels.thermal_inertia(k, ρ, Cₚ)

    thermo_params = AsteroidThermoPPhysicalModels.thermoparams(
        P       = P,
        l       = l,
        Γ       = Γ,
        A_B     = 0.0,
        A_TH    = 0.0,
        ε       = 1.0,
        z_max   = 1.0,
        Nz      = 101,
    )

    println(thermo_params)

    ##= TPMs with different solvers =##
    SELF_SHADOWING = false
    SELF_HEATING   = false
    BC_UPPER       = AsteroidThermoPPhysicalModels.IsothermalBoundaryCondition(0)
    BC_LOWER       = AsteroidThermoPPhysicalModels.IsothermalBoundaryCondition(0)

    stpm_FE = AsteroidThermoPPhysicalModels.SingleTPM(shape, thermo_params; SELF_SHADOWING, SELF_HEATING, BC_UPPER, BC_LOWER, SOLVER=AsteroidThermoPPhysicalModels.ForwardEulerSolver(thermo_params))
    stpm_BE = AsteroidThermoPPhysicalModels.SingleTPM(shape, thermo_params; SELF_SHADOWING, SELF_HEATING, BC_UPPER, BC_LOWER, SOLVER=AsteroidThermoPPhysicalModels.BackwardEulerSolver(thermo_params))
    stpm_CN = AsteroidThermoPPhysicalModels.SingleTPM(shape, thermo_params; SELF_SHADOWING, SELF_HEATING, BC_UPPER, BC_LOWER, SOLVER=AsteroidThermoPPhysicalModels.CrankNicolsonSolver(thermo_params))

    ##= Initial temperature =##
    T₀(x) = x < 0.5 ? 2x : 2(1 - x)
    xs = [thermo_params.Δz * (nz-1) for nz in 1:thermo_params.Nz]
    Ts = [T₀(x) for x in xs]

    stpm_FE.temperature .= Ts
    stpm_BE.temperature .= Ts
    stpm_CN.temperature .= Ts

    ##= Run TPM =##
    for nₜ in eachindex(ephem.time)
        nₜ == length(et_range) && break  # Stop to update the temperature at the final step
        Δt = ephem.time[nₜ+1] - ephem.time[nₜ]
        
        AsteroidThermoPPhysicalModels.forward_euler!(stpm_FE, Δt)
        AsteroidThermoPPhysicalModels.backward_euler!(stpm_BE, Δt)
        AsteroidThermoPPhysicalModels.crank_nicolson!(stpm_CN, Δt)
    end

    ##= Save data =##
    # df = DataFrames.DataFrame(
    #     x = xs,
        # T_FE_100Δt = stpm_FE.temperature[:, 1, 101],  # t =  4 ms <- 0.4e-4 * 100
        # T_BE_100Δt = stpm_BE.temperature[:, 1, 101],  # t =  4 ms
        # T_CN_100Δt = stpm_CN.temperature[:, 1, 101],  # t =  4 ms
        # T_FE_200Δt = stpm_FE.temperature[:, 1, 201],  # t =  8 ms
        # T_BE_200Δt = stpm_BE.temperature[:, 1, 201],  # t =  8 ms
        # T_CN_200Δt = stpm_CN.temperature[:, 1, 201],  # t =  8 ms
        # T_FE_400Δt = stpm_FE.temperature[:, 1, 401],  # t = 16 ms
        # T_BE_400Δt = stpm_BE.temperature[:, 1, 401],  # t = 16 ms
        # T_CN_400Δt = stpm_CN.temperature[:, 1, 401],  # t = 16 ms
        # T_FE_800Δt = stpm_FE.temperature[:, 1, 801],  # t = 32 ms
        # T_BE_800Δt = stpm_BE.temperature[:, 1, 801],  # t = 32 ms
        # T_CN_800Δt = stpm_CN.temperature[:, 1, 801],  # t = 32 ms
    # )
    # jldsave("heat_conduction_1D.jld2"; df)
end

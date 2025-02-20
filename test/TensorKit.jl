# spaces 

@timedtestset "ProductSpace{Vect[Object{Fib}]}" begin
    𝒪 = Object{CategoryData.Fib}
    V1, V2, V3 = Vect[𝒪](1 => 1, 2 => 1), Vect[𝒪](2 => 1),
                 Vect[𝒪](1 => 1, 2 => 1)'
    P = @constinferred ProductSpace(V1, V2, V3)
    @test eval(Meta.parse(sprint(show, P))) == P
    @test eval(Meta.parse(sprint(show, typeof(P)))) == typeof(P)
    @test isa(P, VectorSpace)
    @test isa(P, CompositeSpace)
    @test spacetype(P) == GradedSpace{Object{Fib}, Tuple{Int64, Int64}}
    @test sectortype(P) == Object{Fib}
    @test @constinferred(hash(P)) == hash(deepcopy(P)) != hash(P')
    @test @constinferred(dual(P)) == P'
    @test @constinferred(field(P)) == ℂ
    @test @constinferred(*(V1, V2, V3)) == P
    @test @constinferred(⊗(V1, V2, V3)) == P
    @test @constinferred(adjoint(P)) == dual(P) == V3' ⊗ V2' ⊗ V1'
    @test V1 * V2 * oneunit(V1)' * V3 ==
          @constinferred(insertleftunit(P, 3; conj=true)) ==
          @constinferred(insertrightunit(P, 2; conj=true))
    @test P == @constinferred(removeunit(insertleftunit(P, 3), 3))
    @test fuse(V1, V2', V3) ≅ V1 ⊗ V2' ⊗ V3
    @test fuse(V1, V2', V3) ≾ V1 ⊗ V2' ⊗ V3 ≾ fuse(V1 ⊗ V2' ⊗ V3)
    @test fuse(V1, V2') ⊗ V3 ≾ V1 ⊗ V2' ⊗ V3
    @test fuse(V1, V2', V3) ≿ V1 ⊗ V2' ⊗ V3 ≿ fuse(V1 ⊗ V2' ⊗ V3)
    @test V1 ⊗ fuse(V2', V3) ≿ V1 ⊗ V2' ⊗ V3
    @test fuse(flip(V1) ⊗ V2) ⊗ flip(V3) ≅ V1 ⊗ V2 ⊗ V3
    @test @constinferred(⊗(V1)) == ProductSpace(V1)
    @test @constinferred(one(V1)) == @constinferred(one(typeof(V1))) ==
          @constinferred(one(P)) == @constinferred(one(typeof(P)))
    @test @constinferred(dims(P)) == map(dim, (V1, V2, V3))
    @test @constinferred(dim(P)) == prod(dim, (V1, V2, V3))
    @test @constinferred(dim(one(P))) == 1
    @test first(@constinferred(sectors(one(P)))) == ()
    @test @constinferred(blockdim(one(P), 𝒪(1))) == 1
    for s in @constinferred(sectors(P))
        @test hassector(P, s)
        @test @constinferred(dims(P, s)) == dim.((V1, V2, V3), s)
    end
    @test sum(dim(c) * blockdim(P, c) for c in @constinferred(blocksectors(P))) ==
          dim(P)
end

@timedtestset "HomSpace" begin
    𝒪 = Object{CategoryData.Fib}
    V1, V2, V3, V4, V5 = Vect[𝒪](1 => 1, 2 => 1), Vect[𝒪](2 => 1),
                 Vect[𝒪](1 => 1, 2 => 1)', Vect[𝒪](1 => 1), Vect[𝒪](2 => 1)'
    W = TensorKit.HomSpace(V1 ⊗ V2, V3 ⊗ V4 ⊗ V5)
    @test W == (V3 ⊗ V4 ⊗ V5 → V1 ⊗ V2)
    @test W == (V1 ⊗ V2 ← V3 ⊗ V4 ⊗ V5)
    @test W' == (V1 ⊗ V2 → V3 ⊗ V4 ⊗ V5)
    @test eval(Meta.parse(sprint(show, W))) == W
    @test eval(Meta.parse(sprint(show, typeof(W)))) == typeof(W)
    @test spacetype(W) == GradedSpace{Object{Fib}, Tuple{Int64, Int64}}
    @test sectortype(W) == Object{Fib}
    @test W[1] == V1
    @test W[2] == V2
    @test W[3] == V3'
    @test W[4] == V4'
    @test W[5] == V5'
    @test @constinferred(hash(W)) == hash(deepcopy(W)) != hash(W')
    @test W == deepcopy(W)
    @test W == @constinferred permute(W, ((1, 2), (3, 4, 5)))
    @test permute(W, ((2, 4, 5), (3, 1))) == (V2 ⊗ V4' ⊗ V5' ← V3 ⊗ V1')
    @test (V1 ⊗ V2 ← V1 ⊗ V2) == @constinferred TensorKit.compose(W, W')
    @test (V1 ⊗ V2 ← V3 ⊗ V4 ⊗ V5 ⊗ oneunit(V5)) ==
          @constinferred(insertleftunit(W)) ==
          @constinferred(insertrightunit(W))
    @test @constinferred(removeunit(insertleftunit(W), $(numind(W) + 1))) == W
    @test (V1 ⊗ V2 ← V3 ⊗ V4 ⊗ V5 ⊗ oneunit(V5)') ==
          @constinferred(insertleftunit(W; conj=true)) ==
          @constinferred(insertrightunit(W; conj=true))
    @test (oneunit(V1) ⊗ V1 ⊗ V2 ← V3 ⊗ V4 ⊗ V5) ==
          @constinferred(insertleftunit(W, 1)) ==
          @constinferred(insertrightunit(W, 0))
    @test (V1 ⊗ V2 ⊗ oneunit(V1) ← V3 ⊗ V4 ⊗ V5) ==
          @constinferred(insertrightunit(W, 2))
    @test (V1 ⊗ V2 ← oneunit(V1) ⊗ V3 ⊗ V4 ⊗ V5) == @constinferred(insertleftunit(W, 3))
    @test @constinferred(removeunit(insertleftunit(W, 3), 3)) == W
    @test @constinferred(insertrightunit(one(V1) ← V1, 0)) == (oneunit(V1) ← V1)
    @test_throws BoundsError insertleftunit(one(V1) ← V1, 0)
end

# 
from python import Python
import random
import algorithm.sort as sort
import math


fn generation(
    eliminate: Int,
    inout entity: DynamicVector[SIMD[DType.uint8, 8]],
    fitness_sum: Int,
):
    let p2: Pointer[Int] = Pointer[Int].alloc(entity.size)
    var values: DynamicVector[Int] = DynamicVector[Int]()

    print("Population: ", entity.size)

    for i in range(entity.size):
        let unit = entity[i]

        var sum = 0
        for j in range(8):
            sum += unit[j].to_int() * 2 ** (8 - j - 1)
        sum = fitness_sum - sum
        sum = math.abs(sum)

        p2[i] = sum
        values.push_back(sum)

    sort.sort(values)
    var sorted_entity = DynamicVector[SIMD[DType.uint8, 8]]()

    for i in range(values.size):
        for j in range(entity.size):
            if p2[j] == values[i]:
                sorted_entity.push_back(entity[j])

    print("Before elimination: ", sorted_entity.size)
    for i in range(eliminate):
        let pop = sorted_entity.pop_back()

    print("Eliminated: ", sorted_entity.size)

    # Bitwise mutation
    for i in range(sorted_entity.size):
        var unit = sorted_entity[i]
        let pt1 = DTypePointer[DType.uint8].alloc(1)
        memset_zero(pt1, 1)
        random.randint(pt1, 1, 0, 7)

        for j in range(8):
            if pt1[0] == j:
                unit[j] = 1 - unit[j]

        sorted_entity.push_back(unit)
        pt1.free()

    entity = sorted_entity
    p2.free()


fn main():
    random.seed()

    let fitness: SIMD[DType.uint8, 8] = SIMD[DType.uint8, 8](1, 0, 0, 0, 0, 0, 0, 0)
    let num_entity: Int = 6
    let eliminate: Int = 3
    let generation_num: Int = 5

    var fitness_sum: Int = 0
    for i in range(8):
        fitness_sum += fitness[i].to_int() * 2 ** (8 - i - 1)
    var entity: DynamicVector[SIMD[DType.uint8, 8]] = DynamicVector[
        SIMD[DType.uint8, 8]
    ]()
    for i in range(num_entity):
        let p1 = DTypePointer[DType.uint8].alloc(8)
        memset_zero(p1, 8)
        var a = SIMD[DType.uint8, 8](0)
        for j in range(8):
            random.randint(p1, 8, 0, 1)

            a[j] = p1[j]
        entity.push_back(a)
        p1.free()

    print("Initial population: ")
    for i in range(entity.size):
        print(entity[i])

    for i in range(4):
        generation(eliminate, entity, fitness_sum)

        print("Generation: ", i)
        var sum = 0
        for j in range(entity.size):
            for k in range(8):
                sum += entity[j][k].to_int() * 2 ** (8 - k - 1)
            print(entity[j])
        print("------- average: ", sum / entity.size)

from python import Python
import random
import algorithm.sort as sort
import math


@register_passable
struct Node:
    var distance: Int
    var gene: SIMD[DType.uint8, 8]

    fn __init__(distance: Int, gene: SIMD[DType.uint8, 8]) -> Self:
        return Self {distance: distance, gene: gene}

    fn __copyinit__(existing) -> Self:
        return Self {distance: existing.distance, gene: existing.gene}


fn generation(
    inout entity: Pointer[Node],
    borrowed num_entity: Int,
    fitness_sum: Int,
    eliminate: Int,
):
    let p1: Pointer[Node] = Pointer[Node].alloc(num_entity)
    memset_zero(p1, num_entity)

    # Sort entity by distance (selection sort)
    for i in range(num_entity):
        var least_distance = 100000000
        var least_index = 0

        for j in range(num_entity):
            if entity[j].distance < least_distance:
                least_distance = entity[j].distance
                least_index = j

        p1[i] = entity[least_index]
        entity[least_index].distance = 100000000

    # Eliminate the worst entity (natural selection)
    for i in range(eliminate):
        let last = num_entity - i - 1
        p1[last].distance = 0
        p1[last].gene = SIMD[DType.uint8, 8](0)

    # Birth new entity (Bitwise mutation)
    for i in range(eliminate):
        var parent_gene = p1[i].gene
        # Bitwise mutation
        let random_index = DTypePointer[DType.uint8].alloc(1)
        random.randint(random_index, 1, 0, 7)
        for j in range(8):
            if random_index[0] == j:
                parent_gene[j] = 1 - parent_gene[j]
        random_index.free()

        # Calculate distance
        var sum = 0
        for j in range(8):
            sum += parent_gene[j].to_int() * 2 ** (8 - j - 1)
        p1[num_entity - eliminate + i].distance = math.abs(fitness_sum - sum)
        p1[num_entity - eliminate + i].gene = parent_gene
    # Copy p1 to entity
    memcpy(entity, p1, num_entity)
    p1.free()


fn main():
    # Initialize random seed
    random.seed()
    # Initialize hyperparameters
    let num_entity: Int = 100
    let eliminate: Int = 50
    let generation_num: Int = 10
    # Initialize fitness function (8-bit binary)
    let fitness: SIMD[DType.uint8, 8] = SIMD[DType.uint8, 8](0, 0, 0, 1, 0, 0, 0, 0)
    # Calculate fitness sum
    var fitness_sum: Int = 0
    for i in range(8):
        fitness_sum += fitness[i].to_int() * 2 ** (8 - i - 1)

    # Initialize entity
    var entity: Pointer[Node] = Pointer[Node].alloc(num_entity)
    memset_zero(entity, num_entity)

    for i in range(num_entity):
        # Randomly generate 8-bit binary (gene)
        let p1 = DTypePointer[DType.uint8].alloc(8)
        memset_zero(p1, 8)
        var a = SIMD[DType.uint8, 8](0)
        random.randint(p1, 8, 0, 1)
        # Calculate distance
        var sum = 0
        for j in range(8):
            sum += p1[j].to_int() * 2 ** (8 - j - 1)
            a[j] = p1[j]

        entity[i].distance = math.abs(fitness_sum - sum)
        entity[i].gene = a
        p1.free()

    # Start evolution
    for i in range(generation_num):
        generation(entity, num_entity, fitness_sum, eliminate)
        print("Generation: ", i)
        var sum = 0
        for i in range(num_entity):
            # print(entity[i].gene)
            sum += entity[i].distance
        print("------- average: ", sum / num_entity)

        # Optional: change fitness function
        # let new_fitness: DTypePointer[DType.int8] = DTypePointer[DType.int8].alloc(8)
        # memset_zero(new_fitness, 8)
        # random.randint(new_fitness, 8, 0, 1)

        # var new_fitness_sum: Int = 0
        # for i in range(8):
        #     new_fitness_sum += new_fitness[i].to_int() * 2 ** (8 - i - 1)
        # fitness_sum = new_fitness_sum

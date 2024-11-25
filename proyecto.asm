# Definiciones de variables globales
.data
    slist: .word 0 # Lista de objetos
    cclist: .word 0 # Lista de categorías
    wclist: .word 0 # Categoría actual
    schedv: .space 32 # Vector de funciones del menú
.text
    main:
        # Cargo el vector schedv
        la $t0, schedv 
        
        la $t1, newcaterogy 
        sw $t1, 0($t0) # Guardo la dirección de newcategory en schedv[0]
        
        la $t1, nextcategory
        sw $t1, 4($t0) # Guardo la dirección de newcategory en schedv[1]

        la $t1, prevcategory
        sw $t1, 8($t0) # Guardo la dirección de newcategory en schedv[2]

        la $t1, listcategories
        sw $t1, 12($t0) # Guardo la dirección de newcategory en schedv[3]

        la $t1, delcategory
        sw $t1, 16($t0) # Guardo la dirección de newcategory en schedv[4]

        la $t1, newobject
        sw $t1, 20($t0) # Guardo la dirección de newcategory en schedv[5]

        la $t1, listobjects
        sw $t1, 24($t0) # Guardo la dirección de newcategory en schedv[6]

        la $t1, delobjects
        sw $t1, 28($t0) # Guardo la dirección de newcategory en schedv[7]

    # Menú del programa
    menu: 
        .ascii "Colecciones de objetos categorizados\n"
        .ascii "====================================\n"
        .ascii "1-Nueva categoria\n"
        .ascii "2-Siguiente categoria\n"
        .ascii "3-Categoria anterior\n"
        .ascii "4-Listar categorias\n"
        .ascii "5-Borrar categoria actual\n"
        .ascii "6-Anexar objeto a la categoria actual\n"
        .ascii "7-Listar objetos de la categoria\n"
        .ascii "8-Borrar objeto de la categoria\n"
        .ascii "0-Salir\n"
        .asciiz "Ingrese la opcion deseada: "

    # Mensajes de error y éxito
    error: .asciiz "Error: "
    return: .asciiz "\n"
    catName: .asciiz "\nIngrese el nombre de una categoria: "
    selCat: .asciiz "\nSe ha seleccionado la categoria:"
    idObj: .asciiz "\nIngrese el ID del objeto a eliminar: "
    objName: .asciiz "\nIngrese el nombre de un objeto: "
    success: .asciiz "La operación se realizo con exito\n\n"

    # Primitivas
    newcaterogy:
        addiu $sp, $sp, -4 # Reservo espacio en stack para la dirección de retorno
        sw $ra, 4($sp) # Guardo la dirección de retorno en stack
        la $a0, catName # input category name
        jal getblock
        move $a2, $v0 # $a2 = *char to category name
        la $a0, cclist # $a0 = list
        li $a1, 0 # $a1 = NULL
        jal addnode
        lw $t0, wclist 
        bnez $t0, newcategory_end # Si wclist no es NULL, salto al final
        sw $v0, wclist # update working list if was NULL
    newcategory_end:
        li $v0, 0 # return success
        lw $ra, 4($sp) # Restauro la dirección de retorno
        addiu $sp, $sp, 4 # Libero espacio en stack
        jr $ra
    addnode:
        addi $sp, $sp, -8
        sw $ra, 8($sp)
        sw $a0, 4($sp)
        jal smalloc
        sw $a1, 4($v0) # set node content
        sw $a2, 8($v0)
        lw $a0, 4($sp)
        lw $t0, ($a0) # first node address
        beqz $t0, addnode_empty_list
    addnode_to_end:
        lw $t1, ($t0)                # Obtener el último nodo
        sw $t1, 0($v0)               # Actualizo el puntero 'next' del nuevo nodo
        sw $t0, 12($v0)              # Actualizo el puntero 'prev' del nuevo nodo
        sw $v0, 12($t1)              # Actualizo el 'next' del último nodo
        sw $v0, 0($t0)               # Actualizo el 'prev' del primer nodo
        jr $ra
    addnode_empty_list:
        sw $v0, ($a0)                # Si está vacío, el nuevo nodo es el primero
        sw $v0, 0($v0)               # 'next' apunta a sí mismo
        sw $v0, 12($v0)              # 'prev' también apunta a sí mismo
        jr $ra
    getblock:
        addi $sp, $sp, -4            
        sw $ra, 4($sp)               
        li $v0, 4                    
        syscall
        jal smalloc                  
        move $a0, $v0                
        li $a1, 16                   
        li $v0, 8                    
        syscall
        move $v0, $a0               
        lw $ra, 4($sp)               
        addiu $sp, $sp, 4            
        jr $ra
    
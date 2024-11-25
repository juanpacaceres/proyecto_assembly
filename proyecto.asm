# Definiciones de variables globales
.data
    slist: .word 0 # Lista de objetos
    cclist: .word 0 # Lista de categorías
    wclist: .word 0 # Categoría actual
    schedv: .space 32 # Vector de funciones del menú
    
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

.text
    main:
        # Cargo el vector schedv
        la $t0, schedv 
        
        la $t1, newcategory 
        sw $t1, 0($t0) # Guardo la dirección de newcategory en schedv[0]
        
        la $t1, nextcategory
        sw $t1, 4($t0) # Guardo la dirección de newcategory en schedv[1]

        la $t1, prevcategory
        sw $t1, 8($t0) # Guardo la dirección de newcategory en schedv[2]

        la $t1, listcategories
        sw $t1, 12($t0) # Guardo la dirección de newcategory en schedv[3]

        la $t1, delcategory
        sw $t1, 16($t0) # Guardo la dirección de newcategory en schedv[4]

        #la $t1, newobject
        #sw $t1, 20($t0) # Guardo la dirección de newcategory en schedv[5]

        #la $t1, listobjects
        #sw $t1, 24($t0) # Guardo la dirección de newcategory en schedv[6]

        #la $t1, delobjects
        #sw $t1, 28($t0) # Guardo la dirección de newcategory en schedv[7]

        j start_loop
        
#-------------------------------------------------------------------------------------------   
    # Primitivas
    newcategory:
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
        lw $t1, ($t0) # Obtengo el último nodo
        sw $t1, 0($v0) # Actualizo el puntero 'next' del nuevo nodo
        sw $t0, 12($v0) # Actualizo el puntero 'prev' del nuevo nodo
        sw $v0, 12($t1)# Actualizo el 'next' del último nodo
        sw $v0, 0($t0) # Actualizo el 'prev' del primer nodo
        jr $ra
    addnode_empty_list:
        sw $v0, ($a0) # Si está vacío, el nuevo nodo es el primero
        sw $v0, 0($v0) # 'next' apunta a sí mismo
        sw $v0, 12($v0) # 'prev' también apunta a sí mismo
        jr $ra
    addnode_exit:
        lw $ra, 8($sp)
        addi $sp, $sp, 8
        jr $ra 
        # a0: node address to delete
        # a1: list address where node is deleted
    delnode:
        addi $sp, $sp, -8
        sw $ra, 8($sp)
        sw $a0, 4($sp)
        lw $a0, 8($a0) # get block address
        jal sfree # free block
        lw $a0, 4($sp) # restore argument a0
        lw $t0, 12($a0) # get address to next node of a0
    node:
        beq $a0, $t0, delnode_point_self
        lw $t1, 0($a0) # get address to prev node
        sw $t1, 0($t0)
        sw $t0, 12($t1)
        lw $t1, 0($a1) # get address to first node
    again:
        bne $a0, $t1, delnode_exit
        sw $t0, ($a1) # list point to next node
        j delnode_exit
    delnode_point_self:
        sw $zero, ($a1) # only one node
    delnode_exit:
        jal sfree
        lw $ra, 8($sp)
        addi $sp, $sp, 8
        jr $ra
        # a0: msg to ask
        # v0: block address allocated with string
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
#-------------------------------------------------------------------------------------------  
    nextcategory:
        lw $t0, wclist # Cargo la categoría actual
        beqz $t0, nextcategory_end # Si wclist es NULL, termina
        lw $t1, 0($t0) # Obtengo la dirección del siguiente nodo
        sw $t1, wclist # Actualizo wclist con el siguiente nodo
        li $v0, 0
    nextcategory_end:
        jr $ra
#-------------------------------------------------------------------------------------------  
    prevcategory:
    	lw $t0, wclist 
    	beqz $t0, prevcategory_end # Si wclist es NULL, termina
    	lw $t1, 12($t0)# Obtengo la dirección del nodo anterior
    	sw $t1, wclist # Actualizo wclist con el nodo anterior
    	li $v0, 0               
    prevcategory_end:
    	jr $ra
#-------------------------------------------------------------------------------------------  
    listcategories:
        lw $t0, cclist # Cargo la lista de categorías
        beqz $t0, list_end # Si la lista está vacía, salir
        move $t1, $t0 # Inicio desde el primer nodo
    list_loop:
        lw $a0, 8($t1) # Cargo el nombre de la categoría
        li $v0, 4 # Llamo a syscall para imprimir
        syscall
        li $v0, 4
        la $a0, return       
        syscall
        lw $t1, 0($t1) # Avanzo al siguiente nodo
        bne $t1, $t0, list_loop # Si no hemos vuelto al inicio, seguimos
    list_end:
        jr $ra               
#-------------------------------------------------------------------------------------------  
    delcategory:
        lw $t0, wclist     
        beqz $t0, del_end 
        lw $t1, 0($t0) # Cargo el siguiente nodo
        lw $t2, 12($t0)# Cargo el nodo anterior
        beq $t0, $t1, del_last # Si es el único nodo en la lista, lo elimino
        sw $t1, 0($t2) # Ajusto el puntero 'next' del anterior
        sw $t2, 12($t1) # Ajusto puntero 'prev' del siguiente
        sw $t1, wclist # Actualizo wclist para apuntar al siguiente nodo
        j del_free
    del_last:
        sw $zero, wclist     # Si ese era el único nodo, la lista ahora queda vacía
    del_free:
        move $a0, $t0        # Libero la memoria del nodo actual
        jal sfree
    del_end:
        jr $ra   
#-------------------------------------------------------------------------------------------  
    # Lógica de menú interactivo
    start_loop:
        la $a0, menu # Cargo la dirección del menú
        li $v0, 4 # Imprimo texto ---> (syscall 4)
        syscall
        li $v0, 5 # Leo un número ---> (syscall 5)
        syscall
        move $t0, $v0 # Guardo la opción seleccionada en $t0
        beqz $t0, exit_program # Compruebo si es 0 para salir 
        # Calculo la dirección de la función en schedv
        addi $t1, $t0, -1 # Resto 1 para ajustar las opciones del menú con la indexación del vector schedv
        sll $t1, $t1, 2 # Multiplico por 4 (tamaño palabra) para calcular el offset
        la $t2, schedv # Dirección base del vector schedv
        add $t2, $t2, $t1 # Dirección de la función a llamar
        lw $t3, 0($t2) # Cargo la dirección de la función
        jalr $t3 # Llamo a la función
        j start_loop # Después de haber ejecutado una opción, volvemos al menú
    exit_program:
        li $v0, 10 # Finalizo el programa (syscall 10)
        syscall           
#-------------------------------------------------------------------------------------------
    # Gestión de memoria
    smalloc:
        lw $t0, slist
        beqz $t0, sbrk
        move $v0, $t0
        lw $t0, 12($t0)
        sw $t0, slist
        jr $ra
    sbrk:
        li $a0, 16 # node size fixed 4 words
        li $v0, 9
        syscall # return node address in v0
        jr $ra
    sfree:
        lw $t0, slist
        sw $t0, 12($a0)
        sw $a0, slist # $a0 node address in unused list
        jr $ra
#-------------------------------------------------------------------------------------------  
    # Manejo de objetos
    # Agregar un nuevo objeto a la categoría actual
    newobject:
        addiu $sp, $sp, -4 # Reservo espacio en stack para la dirección de retorno
        sw $ra, 4($sp) # Guardo la dirección de retorno en stack
        lw $t0, wclist               
        beqz $t0, newobject_error    # Si wclist es NULL, error
        la $a0, objName # Muestro mensaje para ingresar el nombre del objeto
        jal getblock
        move $a2, $v0                
        la $a0, 4($t0)              
        li $a1, 0 # $a1 = NULL
        jal addnode                 
        li $v0, 0                  
        j newobject_exit
    newobject_error:
        li $v0, 4
        la $a0, error                # Mensaje de error
        syscall
        li $v0, 0
    newobject_exit:
        lw $ra, 4($sp)               
        addiu $sp, $sp, 4           
        jr $ra

    # Función para listar objetos de la categoría actual
    listobjects:
        lw $t0, wclist # Cargo la categoría actual
        beqz $t0, listobjects_error # Si wclist es NULL, error
        lw $t1, 4($t0)
        beqz $t1, listobjects_empty # Si la lista está vacía, envío mensaje vacío
    listobjects_loop:
        lw $a0, 8($t1) # Cargo el nombre del objeto
        li $v0, 4 # Imprimo el nombre del objeto
        syscall
        li $v0, 4
        la $a0, return               
        syscall
        lw $t1, 0($t1)               # Siguiente nodo
        bne $t1, 4($t0), listobjects_loop # Si no volvemos al inicio, seguimos
        jr $ra
    listobjects_empty:
        li $v0, 4
        la $a0, error 
        syscall
        jr $ra
    listobjects_error:
        li $v0, 4
        la $a0, error
        syscall
        jr $ra

    # Función para eliminar un objeto de la categoría actual
    delobjects:
        beqz $t0, delobjects_error # Si wclist es NULL, error
        lw $t0, wclist # Cargo la categoría actual
        lw $t1, 4($t0) # Cargo la lista de objetos de la categoría actual
        beqz $t1, delobjects_empty 
        la $a0, idObj # Muestra el mensaje para ingresar ID del objeto
        li $v0, 4
        syscall
        li $v0, 5 
        syscall
        move $t2, $v0 # $t2 ---> ID del objeto a eliminar
    delobjects_loop:
        lw $t3, 4($t1) # Obtener el ID del objeto actual
        beq $t3, $t2, delobjects_found # Si coincide, se elimina
        lw $t1, 0($t1)              
        bne $t1, 4($t0), delobjects_loop # Si 
        j delobjects_notfound
    delobjects_found:
        move $a0, $t1 #Dirección del nodo a eliminar
        la $a1, 4($# Lista de objetos
        jal delnode                  
        li $v0, 0                    
        jr $ra
    delobjects_notfound:
        la $a0, error                # "Objeto no encontrado
        syscall
        jr $ra
    delobjects_empty:
        li $v0, 4
        la $a0, error                
        syscall
        jr $ra
    delobjects_error:
        li $v0, 4
        la $a0, error                
        syscall
        jr $ra
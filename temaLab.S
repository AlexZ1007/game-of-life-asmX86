.data
matrix: .space 1600
alternateMatrix: .space 1600


columnIndex: .space 4
lineIndex: .space 4


nrLinii: .space 4
nrColoane: .space 4


nrCeluleVii: .space 4

# Iteratie
k: .space 4

# Index citire
index: .space 4
generatiiIndex: .space 4

# Pentru citire pozitiile unde se insereaza 1
left: .space 4
right: .space 4

# Valordi de testare
decrementedNrLinii: .space 4
decrementedNrColoane: .space 4

# End Valori de testare

formatScanf: .asciz "%d"
formatPrintf: .asciz "%d "
newLine: .asciz "\n"
.text


# Citim nr linii, coloane, celule vii
citire_informatii_generale_matrice:
    pushl %ebp
    movl %esp, %ebp
  
    
    pushl $nrLinii
    pushl $formatScanf
    call scanf
    addl $8, %esp

    addl $2, nrLinii       # add 1 to offset the border of the matrix
    
    pushl $nrColoane
    pushl $formatScanf
    call scanf
    addl $8, %esp

    addl $2, nrColoane       # add 1 to offset the border of the matrix


    pushl $nrCeluleVii
    pushl $formatScanf
    call scanf
    addl $8, %esp


    movl nrLinii, %eax
    movl %eax, decrementedNrLinii
    subl $1, decrementedNrLinii
    movl nrColoane, %eax
    movl %eax,  decrementedNrColoane
    subl $1, decrementedNrColoane


    popl %ebp
    ret

citire_matrice:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi

    movl $0, index
    lea matrix, %edi
    et_for:
        movl index, %ecx
        cmp %ecx, nrCeluleVii
        je exit_citire_matrice

        pushl $left
        pushl $formatScanf
        call scanf
        addl $8, %esp

        addl $1, left   # Same offset, if the input is (0,0) is stored at (1,1)

        pushl $right
        pushl $formatScanf
        call scanf
        addl $8, %esp

        addl $1, right

        # Calculate the element position
        movl left, %eax
        movl $0, %edx
        mull nrColoane
        // %eax := left * nrColoane
        addl right, %eax
        // %eax = left * nrColoane + right

        movl $1, (%edi, %eax, 4)

        movl (%edi, %eax, 4), %ebx

        incl index
        jmp et_for
    exit_citire_matrice:
        popl %edi
        popl %ebp
        ret



# Primeste poz (i,j)
# Intoarce noua valoarea a celulei 1/0 in eax
nouaValoareCelula:
    pushl %ebp
    movl %esp, %ebp
    pushl %edi
    pushl %ebx



    movl 16(%ebp), %eax
    andl $1, %eax

    jz even_number_functie
    jmp odd_number_functie

    even_number_functie:
        lea matrix, %edi
        jmp continuare_logica_functie

    odd_number_functie:
        lea alternateMatrix, %edi
        jmp continuare_logica_functie


    continuare_logica_functie:
    # 8(%ebp) = linie , 12(%ebp) = coloana

    # 6 variabile indexLinie, maxLinie, indexColoana, maxColoana, nr vecinilor vii, valoare initiala celula [i][j]
    # Daca mai adaugam reg salvati scade cu -4, actual avem 2
    subl $24, %esp 


    movl $0, -28(%ebp) # nr vecini vii, initializare

    movl 8(%ebp), %eax 
    movl $0, %edx
    mull nrColoane
    addl 12(%ebp), %eax

    movl (%edi, %eax, 4), %ebx
    movl %ebx, -32(%ebp)

    subl %ebx, -28(%ebp)    # suma incepe cu -1 daca vecinul 1, pt ca este adaugat oricum in for, evita if uri care complica logica
    
    # Increment the given indexes


    movl 8(%ebp), %eax 
    movl %eax, -12(%ebp)
    movl %eax, -16(%ebp)
    subl $1, -12(%ebp)  # Line index
    addl $2, -16(%ebp)  # Max linie index


    movl 12(%ebp), %eax
    movl %eax, -24(%ebp)
    addl $2, -24(%ebp)  # Max column index

    for_lines_proc:
        movl -12(%ebp), %ecx
        cmp %ecx, -16(%ebp)
        je sfarsit_for_vecini
        
        movl 12(%ebp), %eax
        movl %eax, -20(%ebp)
        subl $1, -20(%ebp)  # Column index
        for_columns_proc:
            movl -20(%ebp), %ecx
            cmp %ecx, -24(%ebp)
            je cont_proc

            movl -12(%ebp), %eax
            movl $0, %edx
            mull nrColoane
            addl -20(%ebp), %eax

            movl (%edi, %eax, 4), %ebx
            addl %ebx,  -28(%ebp)       # Contor vecini vii

            incl -20(%ebp)
            jmp for_columns_proc
        cont_proc:

            incl -12(%ebp)
            jmp for_lines_proc
    
    

    sfarsit_for_vecini:

    mov $1, %ebx
    cmp %ebx, -32(%ebp)     
    je celula_vie
    celula_moarta:
        mov $3, %ebx
        cmp %ebx, -28(%ebp)
        je valoare_1
        jmp valoare_0


    celula_vie:
        mov $2, %ebx
        cmp %ebx, -28(%ebp)
        jl valoare_0      #  celule vii < ebx (2)   subpopulare
        mov $3, %ebx
        cmp %ebx, -28(%ebp)
        jg valoare_0        #  celule vii > ebx (3)     suprapoulare
        jmp valoare_1       # ramane in viata


    valoare_0:
        movl $0, %eax
        jmp exit_nouaValoareCelula

    valoare_1:
        movl $1, %eax
        jmp exit_nouaValoareCelula

    exit_nouaValoareCelula:

        addl $24, %esp 
        popl %ebx
        popl %edi
        popl %ebp
        ret


   


.global main

main:

call citire_informatii_generale_matrice
call citire_matrice


# Citire k
pushl $k
pushl $formatScanf
call scanf
addl $8, %esp


# Pentru afisare matrice extinsa

lea matrix, %edi
movl $0, generatiiIndex   
for_generatii:
    movl generatiiIndex, %ecx
    cmp %ecx, k
    je sfarsit_generatii

    movl generatiiIndex, %eax
    andl $1, %eax

    jz even_number
    jmp odd_number

    even_number:
        lea alternateMatrix, %edi
        jmp et_afis_matr
        

    odd_number:
        lea matrix, %edi
        jmp et_afis_matr

    et_afis_matr:
        movl $1, lineIndex
        for_lines:
            movl lineIndex, %ecx
            cmp %ecx, decrementedNrLinii
            je cont_generatii

            movl $1, columnIndex
            for_columns:
                movl columnIndex, %ecx
                cmp %ecx, decrementedNrColoane
                je cont

                movl lineIndex, %eax
                movl $0, %edx
                mull nrColoane
                addl columnIndex, %eax

                movl (%edi, %eax, 4), %ebx

                pushl generatiiIndex
                pushl columnIndex
                pushl lineIndex
                call nouaValoareCelula
                addl $12, %esp
                movl %eax, %ecx     # Save the value returned by function

                movl lineIndex, %eax
                movl $0, %edx
                mull nrColoane
                addl columnIndex, %eax

                movl %ecx, (%edi, %eax, 4)

                incl columnIndex
                jmp for_columns
            cont:
                incl lineIndex
                jmp for_lines


    cont_generatii:
    incl generatiiIndex
    jmp for_generatii    

sfarsit_generatii:

et_afis_matr_final:
    movl $1, lineIndex
    for_lines_final:
        movl lineIndex, %ecx
        cmp %ecx, decrementedNrLinii
        je et_exit

        movl $1, columnIndex
        for_columns_final:
            movl columnIndex, %ecx
            cmp %ecx, decrementedNrColoane
            je cont_final

            movl lineIndex, %eax
            movl $0, %edx
            mull nrColoane
            addl columnIndex, %eax

            movl (%edi, %eax, 4), %ebx

            pushl %ebx
            pushl $formatPrintf
            call printf
            popl %ebx
            popl %ebx

            pushl $0
            call fflush
            popl %ebx

            incl columnIndex
            jmp for_columns_final
        cont_final:
            movl $4, %eax
            movl $1, %ebx
            movl $newLine, %ecx
            movl $2, %edx
            int $0x80

            incl lineIndex
            jmp for_lines_final


et_exit:
    pushl $0
    call fflush
    addl $4, %esp

    mov $1, %eax
    xor %ebx, %ebx
    int $0x80

.data
#AMO AssEMBLY 98765
#myStr0ng p4ssW_
#sempio di messaggio criptato -1
myplaintext: .string "myStr0ng p4ssW_%$"
mysypher: .string "ACBECDDBE"
chiave_a_Blocchi: .string "OLE"

chiave: .string "\nchiave corrente = "
stringa_corrente: .string "\nstringa corrente = "
stringa_cifrata: .string "\nstringa cifrata = "
stringa_decifrata: .string "\nstringa decifrata = "
spazio: .string "\n"
fine: .string "\nFINE"

.text
main:
    la a2, myplaintext # a2 contiene l'indirizzo alla testa della stringa "myplaintext"
    la s0, mysypher   # a3 contiene l'indirizzo alla testa della stringa "myplainext", NON varia MAI
    li a3, 0xFFF      # usato dall'algotimo C_cifraturaOccorrenze, prima d'uso viene salvato in "a2"
    

    li s5, 10 # usato dal algortimo C, per ottenere UNA sola cifra di un indice maggio di 31
    li s7, 9   # per controllo di memorizzazione corretto di indici maggiore di 9 (>=10) che richiedono maggiore di 1 byte per essere memorizzati
    li s8, 48 # viene sommato con indici (in algoritmo C) per rappresentarl in ASCII o viceversa viene sottratta

cifratura:
    li a5, 0 # indica l'indice di ciascun carattere in "mysypher"
    li a6, 0 # nel caso di cifratura a6 = 0
    j carica_chiave
    
decifratura:
    bgt a6, zero, END
    addi a6, a6, 1 # nel caso di decifratura a6 = 1
    li a5, 0       # indica l'indice di ciascun carattere in "mysypher"
    
    add a4, s0, zero # invertire la stringa "mysypher" e leggere ciascun carattere come cifratura
    jal E_inversione  # per invertire  "mysypher"
    
###______________________________________________________________________###   
carica_chiave:
    add t1, a5, s0
    lb t2, 0(t1)
    add a1, t2, zero # a1 viene passato a print_correnti per stampare il carattere
    add a4, a2, zero # a2 viene passato come l'argomento di ogni metodo in a4

    # per stampare la stringa cifrata o decifratta
    beq a5, zero, continua_carica_chiave  # per non stampare la stringa non cifrata
    jal print_dopo_cifraturaDecifratura
    
continua_carica_chiave:
    beq a1, zero, decifratura
    addi, a5, a5, 1   

    # stampare la chiave e stringa corrente
    jal print_correnti

    li t3, 65 # 65 = ASCII (A)
    beq a1, t3, A_cifrarioSostituzione

    li t3, 66 # 66 = ASCII (B)
    beq a1, t3, B_cifrarioBlocchi

    li t3, 67 # 67 = ASCII (C)
    beq a1, t3, C_cifraturaOccorrenze

    li t3, 68 # 68 = ASCII (D)
    beq a1, t3, D_dizionario

    jal E_inversione
     
    j carica_chiave                  # ritorna per caricare la nuova chiave

###______________________________________________________________________###
A_cifrarioSostituzione:
    li a0, 0
    li a1, 0
    li s1, -84   # s1 contiene la chiave k, che indica lo shift alfabetico
cifrarioSostituzione_loop:
    jal MR_RM # il carattere viene memorizzato in a0, suo indice viene memeorizzato in a1
    beq a0, zero, end_cifrarioSostituzione
    
    li t5, 26
    
    li t4, 64 # ASCII(A) -1
    sltiu t2, a0, 91 # ASCII(Z) +1      # sostituzione dei maiuscoli
    sltu t3, t4, a0
    beq t2, t3, cifrarioSostituzione_CifDecif
    
    li t4, 96 # ASCII(a) -1
    sltiu t2, a0, 123 # ASCII(z) +1      # sostituzione dei minuscoli
    sltu t3, t4, a0
    beq t2, t3, cifrarioSostituzione_CifDecif
    
    j cifrarioSostituzione_loop
    
                         ###****************************### 
                             
cifrarioSostituzione_CifDecif:
    addi t4, t4, 1                         # t4 contiene ASCII(A)=65 (oppure ASCII(a)=97)
    sub a0, a0, t4                         # cod(y) - t4 , y = carattere da decifrato,  cod(x) - t4 , x = carattere da cifrato
    beq a6, zero, cifrarioSostituzione_Cif # controllo lo stato di cifratura o decifratura
    
cifrarioSostituzione_Decif:
    sub a0, a0, s1  # [(cod(y)-t4) - k]
    j cifrarioSostituzione_CifDecif_continua
    
cifrarioSostituzione_Cif:
    add a0, a0, s1 # [(cod(X)-t4) + k]
    
cifrarioSostituzione_CifDecif_continua:
    jal resto_positivo                      # viene chiamato per ottnenere il dividendo corretto
    
    rem a0, a0, t5                          # [(cod(X)-65) + k] % 26
    add a0, a0, t4                          # [(cod(X)-65) + k] % 26 + (65 oppure 97)
    j cifrarioSostituzione_loop    
    
end_cifrarioSostituzione:
    j carica_chiave                         # alla fine salta a invocare il nuovo algortimo cif/decif 
    
                         ###****************************###    
   
resto_positivo:
    bge a0, zero, end_resto_positivo
    add a0, a0, t5
    rem a0, a0, t5
    j resto_positivo
end_resto_positivo:
    jr ra    

###______________________________________________________________________###
B_cifrarioBlocchi:
    add t3, a4, zero       # memorizzo l'indirizzo alla testa della stringa in un registro
    la a4, chiave_a_Blocchi
    jal length
    add s2, a0, zero        # s1 contiene la lunghezza della chiave_a_blocchi
    add s3, a4, zero        # s3 contiene l'indirizzo alla testa della chiave_a_blocchi
    add a4, t3, zero        # recupero l'indirizzo alla testa della stringa (memorizzando di nuovo in a4)

                         ###****************************### 

    li t0, 0
    li t5, 96
    li t6, 32
cifrarioBlocchi_key_char:
    add t1, t0, a4
    lb a0, 0(t1)                   # a0 contiene il carattere da cifrare
    beq a0, zero, end_cifrarioBlocchi
    
    rem t3, t0, s2                 # t3 contine  0=< indice(= t0 % s2) <= a1 
    add t3, t3, s3                 # l'indirizzo alla testa + indice dalle chiave_a_blocchi
    lb t4, 0(t3) 
 
      
distinzione_cifratura_decifratura:
    bne a6, zero, decifrario_a_Blocchi
    
    # cifratura a blocchi
    add a0, a0, t4
    rem a0, a0, t5
    add a0, a0, t6
    sb a0, 0(t1)
    
    j incremento_indice_Key_char
    
decifrario_a_Blocchi:
    sub a0, a0, t6                           # cb - 32
    sub a0, a0, t4                           # (cb - 32) - cod(key)    
    jal divisore_corretto                    # usato per arrivare al dividendo corretto
    sb a0, 0(t1) 
      
incremento_indice_Key_char:
    addi t0, t0, 1
    j  cifrarioBlocchi_key_char

end_cifrarioBlocchi:
    j carica_chiave             # alla fine salta a decifratura/ decifratura         

                         ###****************************###  
divisore_corretto:
    bge a0, t6, end_divisore_corretto     
    add a0, a0, t5
    j divisore_corretto
end_divisore_corretto:
    jr ra            
###______________________________________________________________________###
# riceve come argomento a4 che contiene a2 (l'indirizzo alla testa della stringa da cifrare/decifrare)
# l'indirizzo alla testa della nuova stringa (a3) viene memorizzato in a2
# alla fine a3 = a3 + indice dell'ultimo carattere aggiunto in a2

C_cifraturaOccorrenze:
    bne a6, zero,  C_decifraturaOccorrenze
    add a2, a3, zero                            # passare nuovo l'indirizzo a a2 che conterra la stringa risultatnte alla fine
    li a0, 0
    li a1, 0
    li s4, -1                                   # messo uguale a "-1" per NON per eviatre il primo confornto
    jal carica_del_carattere                    # carica del primo carattere nel registro a0
    add s4, a0, zero                            # s4 contiene il carattere da confrontare e caricare al posto di letti                     
    j continua_carica_dei_caratteri
C_carica_dei_caratteri: 
    jal carica_del_carattere                           
continua_carica_dei_caratteri:
    li t0, 0 
    li t1, 45                                    # t1 contiene codice ASCII del trattino
    
    add t2, t0, a3        # carica dei caratteri, a partire dal NUOVO indirizzo
    sb a0, 0(t2) 

carica_delle_occorrenza:
    add t3, a1, zero
carica_delle_occorrenza_loop:
    add t4, t3, a4
    lb t5, -1(t4)          # poich? a1 contiene i+1, allora la sua dimensione viene ridotto di 1 una
    beq t5, zero, end_questa_occorrenza # indica la fine, poich? non ci saranno pi? caratteri uguali a "a0"
    bne t5, a0, incremento_indice_loop
    
    addi t0, t0, 1        # carica del trattino in memoria
    add t2, t0, a3
    sb t1, 0(t2)

    bgt t3, s7, indiciGrandi # va a indiciGrandi, se indice sta maggiore di 9 e ha bisogno pi? di 1 byte per essere memorizzato
    add s6, t3, s8   # trasformazre valore puro in ASCII
    jal carica_inMemoria

riempire_visitati:
    li t1, 45  
    sb s4, -1(t4)          # carica  della carattere usato per eseguire i confronti e evitare duplicati
incremento_indice_loop:
    addi t3, t3, 1
    j carica_delle_occorrenza_loop
end_questa_occorrenza:
    li t1, 32
    addi t0, t0, 1
    add t2, t0, a3
    sb t1, 0(t2)
      
    add a3, t0, a3
    addi a3, a3, 1
    j C_carica_dei_caratteri
    
                         ###****************************###  
                         
carica_del_carattere:
    add t1, a1, a4
    lb a0, 0(t1)
    beq a0, zero, end_cifraturaOccorrenze
    addi a1, a1, 1
    beq a0, s4, carica_del_carattere              # controllo di ugualianza con s4 solo per la cifratura
    jr ra
end_cifraturaOccorrenze:
    sb zero, -1(a3)            # scambio l'ultimo spazio (BYTE) con uno zero, per indicare la fine della stringa
    j carica_chiave             # alla fine salta a decifratura/ decifratura 
    
                         ###****************************###  
                         
# s5 contiene il valore 10 da dividere, o calcolare il resto
# stato implementato per la memorizzazione dei indici maggiore di 255 che richiedono maggiore di un byte per essere memorizzati      
indiciGrandi:
    add t5, t3, zero
    li t6, 0
indiciGrandi_loop:
    beq t5, zero, carica_delle_cifre_inMemoria
    rem t1, t5, s5 
    jal carica_delle_cifre_nelloStack               # calcolo del resto rispetto a s5, per ottenere la prima cifra
                                   
    div t5, t5, s5                                  # calcolo della divisione per s5, per eliminare la cifra memorizzata
    j indiciGrandi_loop
    
    
                         ###****************************###  
             
carica_delle_cifre_nelloStack:
    addi sp, sp, -4           # allocazione dello spazio nello stack e 
    sb t1, 0(sp)              # caricamento della cifra in una posizine
    addi t6, t6, 1            # t6 indica la lunghezza dello stack (il numero dei valori inseriti nello stack)
    jr ra                     # ritorna al chiamante
carica_delle_cifre_inMemoria:
    addi t6, t6, -1
    lb t1, 0(sp)              # scaricamento della cifra dallo stack
    addi sp, sp, 4            # liberare lo spazio occupato dalla cifra gia caricata
    
    add s6, t1, s8   # trasformazre valore puro in ASCII
    jal carica_inMemoria
    
    bgt t6, zero, carica_delle_cifre_inMemoria 
    j  riempire_visitati
    
carica_inMemoria:
    addi t0, t0, 1        # carica della occorrenza in memoria come un valore puro in 1 byte
    add t2, t0, a3
    sb s6, 0(t2)
    jr ra                           
###______________________________________________________________________###
C_decifraturaOccorrenze:
    li t6, 0             # PER CONTROLLO DEL INDICE ***********
    add a2, a3, zero
    li a0, 0
    li a1, 0
    li t5, 0
decifOc_caricaCarattere:
    jal carica_del_carattere_decif
    addi a1, a1, 1           # dopo un char appare sempre un TRATTINO, allora incremento a1 di 1, per evitare il suo confornto
    li t0, 32 # ASCII spazio
    li t1, 45 # ASCII trattino
decifOc_caricaOccorrenze:
    add t2, a1, a4
    lb t3, 0(t2) 

    beq t3, zero, termine_occorrenza         #  la_fine_stringa -> termina
    beq t3, t0, carica_carattere_successivo  #  spazio -> carattere successivo da aggiungere
    beq t3, t1, incremento_contatore          # trattino -> occorrenza successiva in cui aggiungere il carattere
cercaIndice:
    sub t3, t3, s8
    
    addi sp, sp, -4
    sb t3, 0(sp)
    addi t6, t6, 1 # carica del valore puro nello stack e incrementa t6 di 1 unita
     
    addi a1, a1, 1
    add t2, a1, a4
    lb t3, 0(t2) 
    
    # ordine sta importante 1_ ctronllo spazio 2_ controllo null (fine stringa) 3_controllo !(trattino)
    beq t3, t0, calcolaIndice     # 49 | space   49 | 51 | space   
    beq t3, zero, calcolaIndice   # 49 | 0       49 | 51 | 0 
    bne t3, t1, cercaIndice     # 49 | 53      49 | 51 | 53
calcolaIndice:
    addi a1, a1, -1         # riduzione a1 nel caso in cui il carattere sta spazio/-/0
    li t2, 1                # valore moltiplicato per 10, prima di essere moltiplicato per la cifra
    li t3, 0
calcolaIndice_loop:
    beq t6, zero, calcolaIndice_loop_end
    lb t4, 0(sp)
    addi sp, sp, 4
   
    mul t4, t4, t2 # t4*t2
    mul t2, t2, s5 # t2*s5 = 1, 10, 100, 1000
    add t3, t3, t4 # contine alla fine indice corretto
    
    addi t6, t6, -1
    j calcolaIndice_loop
calcolaIndice_loop_end:            
    addi t5, t5, 1                         # indica la lunghezza della nuova stringa (finale)
          
                         ###****************************###  
       
continua_indice_positivo:
    add t3, t3, a3              # carica del carattere (memorizzato a0) nella posizione [(t3-1) + nuovo_indirizzo]
    sb a0, -1(t3)    
incremento_contatore:           # nel caso in cui trova un TRATTINO
    addi a1, a1, 1
    j decifOc_caricaOccorrenze

                         ###****************************###  
     
carica_carattere_successivo:     # nel caso in cui trova uno SPAZIO
     addi a1, a1, 1
    j decifOc_caricaCarattere
termine_occorrenza:              # nel caso in cui trova la_fine_stringa
    add a3, a3, t5
    addi a3, a3, 2              # nuovo_indirizzo
    j carica_chiave             # alla fine salta a decifratura/ decifratura 

                         ###****************************###  
                         
carica_del_carattere_decif:
    add t1, a1, a4
    lb a0, 0(t1)
    addi a1, a1, 1
    jr ra  
    
    
###______________________________________________________________________###
D_dizionario:
    li a0, 0
    li a1, 0
D_dizionario_loop:
    jal MR_RM # viene chiamato per ottenere il carattere (memorizzato in a0) e suo indice (memorizzato in a1)
    beq a0, zero, end_dizionario
    
    li t4, 64 # ASCII(A) -1
    sltiu t2, a0, 91 # ASCII(Z) +1      # sostituzione dei maiuscoli
    sltu t3, t4, a0
    beq t2, t3, sostituzione_MAIUSCOLO_minuscolo
    
    li t4, 96 # ASCII(a) -1
    sltiu t2, a0, 123 # ASCII(z) +1      # sostituzione dei minuscoli
    sltu t3, t4, a0
    beq t2, t3, sostituzione_MAIUSCOLO_minuscolo
    
    li t4, 47 # ASCII(0) -1
    sltiu t2, a0, 58 # ASCII(9)+1        # sostituzione dei numeri
    sltu t3, t4, a0
    beq t2, t3, sostituzione_numero

end_sostituzione_alfanumerici:
     j D_dizionario_loop                 # altri caratteri restano invariati   
                         
sostituzione_MAIUSCOLO_minuscolo:
    li t4, 187
    sub a0, t4, a0 
    j end_sostituzione_alfanumerici

sostituzione_numero:
     li t4, 105
     sub a0, t4, a0
    j end_sostituzione_alfanumerici

end_dizionario:
    j carica_chiave             # alla fine salta a decifratura/ decifratura 
    
                         ###****************************###   
                          
# usato per
# 1_caricare un BYTE dalla memoriza in a0 (MR)
# 2_ salvare l'indice di tale carattere in a1
# 3_ caricare un BYTE dal registro in memoria (RM)  

MR_RM:
    add t0, a1, a4
    blt a1, zero, continua_senzaSB
    sb a0, -1(t0)                  # -1 poich? nel primo passo non viene eseguito SB
continua_senzaSB:
    lb a0, 0(t0)
    addi a1, a1, 1
    jr ra
    
###______________________________________________________________________###
E_inversione:                  
    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal length        # per calcolo della lunghezza della stringa (che viene restituito in a0)
    addi a0, a0, -1   # a0 = (lunghezza della stringa - la fine_della _stringa)
    li t0, 0
inversione_loop:
    bgt t0, a0, end_inversione
    
    add t1, t0, a4
    add t2, a0, a4
    
    # swap
    lb t3, 0(t1)
    lb t4, 0(t2)
    
    sb t3, 0(t2)
    sb t4, 0(t1)
    
    addi t0, t0, 1  # incremento i (indice alla testa)
    addi a0, a0, -1 # decremento j (indice alla coda)
    
    j inversione_loop
    
end_inversione:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra


##### usato per il calcolo della lunghezza della stringa #####

length:
    li t0, 0
length_loop:
    add t1, t0, a4
    lb t2, 0(t1)
    beq t2, zero, end_length
    
    addi t0, t0, 1
    j length_loop
end_length:
    add a0, t0, zero  # lunghezza con la fine della stringa
    jr ra

###______________________________________________________________________###        
print_correnti:
    addi sp, sp, -4
    sw ra, 0(sp)
#-----------------     
    la a0, chiave              # print "chiave corrente = "
    li a7, 4
    ecall
    
    add a0, a1, zero           # print la chiave corrente (ricevuto in a1)
    li a7, 11
    ecall
    
    la a0, stringa_corrente    # print "stringa corrente = "
    li a7, 4
    ecall
    
    add a0, a4, zero           # print la stringa corrente
    li a7, 4
    ecall          
#-----------------      
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra                      # ritorna a AVVISO delle fasi

###______________________________________________________________________###
print_dopo_cifraturaDecifratura:
    addi sp, sp, -4
    sw ra, 0(sp)
    bne a6, zero, print_decifratura
    
print_cifratura:
    la a0, stringa_cifrata     # print "stringa cifrata = "
    li a7, 4
    ecall
    
    j end_print
        
print_decifratura:
    la a0, stringa_decifrata    # print "stringa decifrata = "
    li a7, 4
    ecall

end_print:
    
    add a0, a4, zero            # print "stringa "
    li a7, 4
    ecall
    
    la a0, spazio                      # per stampare spazi tra cifrature e decifrature
    li a7, 4
    ecall 
 
    lw ra, 0(sp)
    addi sp, sp, 4    
    jr ra # ritorna alla fine, al chiamante

###______________________________________________________________________###    
END:
    la a0, fine
    li a7, 4
    ecall
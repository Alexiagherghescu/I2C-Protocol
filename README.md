# I2C-Protocol

O tranzactie de date prin intermediul protocolului I2C are urmatorii pasi:  
1. Conditia de start este trimisa de catre Master: - SDA are o tranzitie din high in low cat timp SCL inca este high  
2. Este transmisa adresa addr_slave + un bit de write (7 biti de adresa + 1'b0 pentru write ) catre slaves(0x4B)  
3. Fiecare Slave compara adresa iar cel cu care aceasta se potriveste transmite inapoi catre Master un ACK bit, care dureaza un singur ciclu de scl  
  ACK si NACK sunt transmise de modulul care primeste datele in acel moment pentru confirmarea/neconfirmarea receptiei acestora. Modulele vor fi implementate utilizand ACK, adica sda va fi trasa in 0 logic pentru un ciclu de ceas pentru a confirma receptionarea datelor/adreselor.

Avand in vedere ca vrem sa citim temperatura de pe senzorul ADT :    

5. Este trimisa adresa registrului din care vrem sa citim (temperatura se afla in registrele:0x00 si 0x01)- Conform DataSheet ului la alimentare temperatura este citita automat din acest registru , insa vom scrie implicit adresa de la care vrem sa citim pentru a ne asigura ca citim exact ce trebuie.
6. Slave genereaza un semnal de ACK pentru validare.
7. Se genereaza un semnal de RESTART: initial SCL si SDA sunt in 0 asa ca va trebui sa tragem SDA in HIGH , iar mai apoi pe SCL in HIGH pentru a nu genera o conditie de STOP, si cat timp SCL e high sa tragem SDA in LOW (ca intr-o conditie normala de start)
8. Masterul trimite iar addr_slave + 1 bit de read catre senzor pentru a schimba directia transmisiei datelor si pentru a citi datele de la registrul indicat de pointerul setat anterior
9. Slave genereaza iar semnal de ACK  
10. Masterul primeste primii 8 biti de date care reprezinta MSB ul  si trimite semnal de ACK catre Slave pentru a semnaliza ca au fost receptionati
11. Dupa informatiile din DataSheet senzorul are functie de autoincrementare asa ca nu este necesara incrementarea adresei, va citi automat de la adresa 0x01 bitii de date de temperatura dupa generarea semnalului de ACK  
12. De data aceasta se genereaza un semnal de NACK, adica ACK este setat la High Impedance sau 1'bz pentru un ciclu de ceas pentru a semnaliza ca a terminat de citit datele si pentru a elibera linia de SDA.  
13. Conditia de STOP este transmisa de catre Master : dupa punctul 12 SCL este in 0L si SDA este in 1L(1'bz), SDA trebuie tras in 0L, iar apoi SCL trebuie ridicat cat timp SDA este inca 0L, iar mai apoi SDA trebuie adus si el in starea HIGH pentru a respecta conditia de stop

Schimbarea datelor se face doar cat timp SCL este in starea LOW, iar citirea datelor se realizeaza atunci cand SCL este HIGH.   

# SCL si Clock Divider
Pentru a genera semnalul SCL am gandit implementarea unui modul de Clock Divider sau Timer care trimite un semnal done_tick catre FSM care va fi folosit pentru temporizarea transferului de date.  

Modulul a fost parametrizat pentru flexibilitate:  

Final_Val     = CLOCK_FREQ/Tick_FREQ este valoarea pana la care trebuie sa numere counterul pentru a ajunge la frecventa dorita pentru I2C  
Tick_FREQ     = I2C_FREQ*sample este frecventa tick urilor , iar sample este un parametru ales implicit la 4 care reprezinta numarul de tick uri intr un ciclu de ceas al I2C_CLOCK
Counter_Width = $clog2(Final_Val) este latimea counterului care se adapteaza in functie de frecventa dorita pentru I2C.

# Timing
Semnalul de done tick care provine de la Clock Divider trimite 4 impulsuri pe durata unui bit . Aceste 4 impulsuri sunt numarate in interiorul I2C Master printr-un contor intern numit q_tick. Fragmentarea unui bit in 4 intervale este necesara pentru respectarea conditiilor de set up time si hold time. Schimbarea datelor pe SDA se realizeaza atata timp cat SCL este 0. Dupa ce datele au fost schimbate SCL trebuie sa ramana tot pe 0 pentru stabilizarea datelor. SCL este ridicat in 1 pentru a citi datele in al 3-lea q_tick, iar apoi este lasat in 1 pentru cel de-al 4 lea ciclu pentru a respecta conditia de hold time.
Am folosit un bloc de tip case pentru a reprezenta semnalele scl si sda in fiecare stare a FSM ului.
# Alte registre folosite in realizarea I2C MASTER:
Am avut nevoie de un registru care sa numere bitii numit bit_count. Acest registru se decrementeaza pentru parcurgerea bitilor de date.
Avem un registru intern shiftreg care contine datele pe care vrem sa le transmitem/ care urmeaza a fi receptionate.
Deoarece este un protocol de comunicare seriala , atunci cand transmitem sau receptionam un bit ne folosim de shiftreg[bit_count], unde bit_count reprezinta pozitia bitului din shift_reg.

# Modificarea modulelor anterioare:
Am importat in noul proiect modulele temelor anterioare:   
  -UART Logger interactiv 
  -MUX  
  -Afisaj 7seg  
  -Timer.  

    
Pentru a afisa temperatura in grade Celsius pe consola am inceput prin modificarea modulului Command  unde am adaugat o noua comanda in meniu: 'T/t '.
De asemenea au intervenit modificari si la modulul FSM mesaj pentru a putea afisa mesajul: "Temperatura este:....C" , care constau in :  
 -adaugarea unor noi inputuri: message_temp activat de modulul command la primirea comenzii "T/t" si  temp_val care provine de la binary_to_ascii cu valoarea     temperaturii convertite in ascii pentru a putea fi afisata pe consola
 -adaugarea unei noi stari in FSM care sa fie activata de comanda "T/t"   

 Pentru modulul Binary to ASCII din interiorul modulului UART logger interactiv am adaugat o intrare temp_converted provenita de la un modul BCD  care are rolul de a desparti pe unitati valoarea in binar provenita de la CTRL_Senzor si o iesire temp_val care ne va folosi la afisarea pe consola.   

Modulului UART logger interactiv i-am adaugat un alt input temp_converted care provine din modulul BCD si am realizat conectarea interna a semnalelor noi enunate mai sus.   

# Module noi  
## BCD 
Initial modulul ASCII nu functiona corect intrucat el primea o valoare in binar pe care o transforma in hexa iar mai apoi in ascii. Daca imparteam valoarea in binar primita de la ctrl senzor in 3 seturi a cate 4 biti si treceam aceasta valoare prin modulul nostru de conversie, pe ecran ar fi aparut litere pentru valori in binar mai mari decat 9. Astfel, introducand un nou modul BCD care primeste valoarea in binar de la CTRL_senzor , acesta scoate valoarea in binar pentru fiecare cifra a numarului primit : zeci, unitati si zecimala. Prin concatenarea in modulul top a acestor semnale si conectarea la temp_converted , valoarea corecta este trimisa catre modulul ASCII . 

De asemenea modulul BCD va ajuta si la afisarea pe 4 digits a temperaturii


## Timer pentru citirea periodica a temperaturii
Este necesar un modul care sa genereze un semnal de enable pentru I2C master . Deoarece vrem sa citim periodic temperatura provenita de la senzor acest modul va fi parametrizat pentru flexibilitate pentru a citi la diferite intervale de timp, usor de modificat in functie de cerinta.
Intern, acest modul este un counter care numara pana la o valoare care se actualizeaza automat in functie de intervalul de timp la care vrem sa se faca citirea si trimite un semnal de done care actioneaza ca semnal de enable pentru I2C Master.

## CTRL_Senzor
Acest modul preia temperatura in formatul de 16 biti din registrele interioare 0x00-0x01 ale senzorului ADT pde pe iesirea data_out a modulului I2C_Master si prelucreaza datele astfel incat sa preia doar informatia referitoare la temperaturaa in grade Celsius.

 

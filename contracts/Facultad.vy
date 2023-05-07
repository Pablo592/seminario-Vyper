# @version ^0.3.7

# External Interfaces
interface Carrera:
    def establecerDuenio(decano: address): nonpayable
    def inscribirEstudiante(dni: uint32, estudiante: address): nonpayable
    def verInscriptos(decano: address) -> DynArray[uint32, 30]: nonpayable
    def destroy(decano: address): nonpayable


# Events #######
event MontoAPagar:
    costoDeLaCuota: uint256


event CarreraCreada:
    nombre: String[30]


event EstudianteRegistrado:
    nombre: String[30]
    apellido: String[30]
    dni: uint32

event EstudianteInscriptoEnCarrera:
    nombreCarrera: String[30]

event EstudiantePresentaAnalitico:
    analitico: bytes32

################

# Structs ######
struct Inscripto:
    pagado: bool
    analitico: bytes32
    dni: uint32
    nombre: String[30]
    apellido: String[30]
 
struct Carreras:
    carrera: Carrera
    nombre: String[30]
##################    

# Hash Maps ######
inscriptos: HashMap[address, Inscripto]
carreraLista: HashMap[String[30], Carreras]
dniRegistrados: HashMap[uint32, uint32]

# Variables varias #####
nombres: DynArray[String[30], 30]
montoInscripcion: uint256
decano: address
recaudacion: uint256
########################

@external
def __init__(montoInscripcion: uint256):
    self.decano = msg.sender
    self.montoInscripcion = montoInscripcion


@external
def resgistrarEstudiante(nombre: String[30], apellido: String[30],dni: uint32):
    assert self.decano != msg.sender, "El decano no puede ser estudiante"
    assert self.inscriptos[msg.sender].dni == 0, "Este estudiante ya se encuentra registrado"
    assert self.dniRegistrados[dni] == 0, "No se aceptan los DNI duplicados"

    self.dniRegistrados[dni] = dni
    self.inscriptos[msg.sender].dni = dni
    self.inscriptos[msg.sender].apellido = apellido
    self.inscriptos[msg.sender].nombre = nombre
    log EstudianteRegistrado(nombre,apellido,dni)

@external
def resgistrarEstudianteAnalitico(analitico: bytes32):
    assert self.inscriptos[msg.sender].dni != 0, "Este estudiante no se encuentra registrado"
    assert self.inscriptos[msg.sender].analitico == 0x0000000000000000000000000000000000000000000000000000000000000000, "Su analitico ya se encuentra registrado"
    self.inscriptos[msg.sender].analitico = analitico
    log EstudiantePresentaAnalitico(analitico)


@external
@payable
def pagarInscripcion():
    log MontoAPagar(self.montoInscripcion)
    assert self.inscriptos[msg.sender].dni != 0, "Este estudiante no se encuentra registrado"
    assert self.montoInscripcion == msg.value , "El monto ingresado no es el adecuado"
    assert not self.inscriptos[msg.sender].pagado , "Ya ha pagado la inscripcion"
    self.recaudacion += msg.value
    self.inscriptos[msg.sender].pagado = True


@external
def inscribirEnCarrera(nombreCarrera: String[30]):
    assert self.inscriptos[msg.sender].dni != 0, "Este estudiante no se encuentra registrado"
    assert self.inscriptos[msg.sender].analitico != 0x0000000000000000000000000000000000000000000000000000000000000000, "Este estudiante todavia no ha presentado su analitico"
    assert self.inscriptos[msg.sender].pagado, "Este estudiante todavia no ha pagado su inscripcion"
    assert self.carreraLista[nombreCarrera].nombre != "", "Esta carrera no se encuentra creada"
    self.carreraLista[nombreCarrera].carrera.inscribirEstudiante(self.inscriptos[msg.sender].dni,msg.sender)
    log EstudianteInscriptoEnCarrera(nombreCarrera)
    pass



@external
def generarCarrera(dreccionContrato:address, nombre: String[30]):
    assert self.decano == msg.sender, "Solo el decano puede generar carreras"
    assert self.carreraLista[nombre].nombre == "", "Esta carrera ya se encuentra creada"
    self.carreraLista[nombre].carrera = Carrera(dreccionContrato)
    self.carreraLista[nombre].carrera.establecerDuenio(self.decano)
    self.carreraLista[nombre].nombre = nombre
    self.nombres.append(nombre)
    log CarreraCreada(nombre)
    pass


@external
def estudiantesDeCarrera(nombreCarrera: String[30])-> DynArray[uint32, 30]:
    assert self.decano == msg.sender, "Solo el decano puede llamar a esta funcion"
    assert self.carreraLista[nombreCarrera].nombre != "", "Esta carrera no se encuentra creada"
    return self.carreraLista[nombreCarrera].carrera.verInscriptos(msg.sender)

@external
def cerrarInscripciones():
    assert self.decano == msg.sender, "Solo el decano puede destruir el contrato"
    for i in self.nombres:
        self.carreraLista[i].carrera.destroy(msg.sender)
    selfdestruct(msg.sender)
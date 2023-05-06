# @version ^0.3.7

# External Interfaces
interface Carrera:
    def inscribirEstudiante(dni: uint32, estudiante: address): nonpayable
    def verInscriptos() -> uint32[30]: nonpayable
    
struct Inscripto:
    pagado: bool
    analitico: bytes32
    dni: uint32
    nombre: String[30]
    apellido: String[30]

    
struct Carreras:
    carrera: Carrera
    nombre: String[30]
    


montoInscripcion: uint256

event MontoAPagar:
    costoDeLaCuota: uint256

decano: address
inscriptos: HashMap[address, Inscripto]
carreraLista: HashMap[String[30], Carreras]
dniRegistrados: HashMap[uint32, uint32]
recaudacion: uint256

@external
def __init__(montoInscripcion: uint256):
    self.decano = msg.sender
    self.montoInscripcion = montoInscripcion


@external
def resgistrarEstudiante(nombre: String[30], apellido: String[30],dni: uint32):
    assert self.inscriptos[msg.sender].dni == 0, "Este estudiante ya se encuentra registrado"
    assert self.dniRegistrados[dni] == 0, "No se aceptan los DNI duplicados"

    self.dniRegistrados[dni] = dni
    self.inscriptos[msg.sender].dni = dni
    self.inscriptos[msg.sender].apellido = apellido
    self.inscriptos[msg.sender].nombre = nombre

@external
def resgistrarEstudianteAnalitico(analitico: bytes32):
    assert self.inscriptos[msg.sender].dni != 0, "Este estudiante no se encuentra registrado"
    self.inscriptos[msg.sender].analitico = analitico


@external
@payable
def pagarInscripcion():
    log MontoAPagar(self.montoInscripcion)
    assert self.montoInscripcion == msg.value , "El monto ingresado no es el adecuado"
    self.recaudacion += msg.value
    self.inscriptos[msg.sender].pagado = True


@external
def inscribirEnCarrera(nombreCarrera: String[30]):
    self.carreraLista[nombreCarrera].carrera.inscribirEstudiante(self.inscriptos[msg.sender].dni,msg.sender)
    pass



@external
def generarCarrera(nombre: String[30]):
    assert self.decano == msg.sender, "Solo el decano puede generar carreras"
    assert self.carreraLista[nombre].nombre == "", "Esta carrera ya se encuentra creada"
    self.carreraLista[nombre].carrera = Carrera(msg.sender)
    self.carreraLista[nombre].nombre = nombre
    pass


@external
def estudiantesDeCarrera(nombreCarrera: String[30])-> uint32[30]:
    assert self.decano == msg.sender, "Solo el decano puede generar carreras"
    return  self.carreraLista[nombreCarrera].carrera.verInscriptos()
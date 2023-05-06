# @version ^0.3.7

struct Inscripto:
    pagado: bool
    analitico: bytes32
    dni: uint32
    nombre: uint32
    apellido: uint32

montoInscripcion: uint256

event MontoAPagar:
    costoDeLaCuota: uint256

decano: address
inscriptos: HashMap[address, Inscripto]
dniRegistrados: HashMap[uint32, uint32]
recaudacion: uint256

@external
def __init__(montoInscripcion: uint256):
    self.decano = msg.sender
    self.montoInscripcion = montoInscripcion


@external
def resgistrarEstudiante(nombre: uint32, apellido: uint32,dni: uint32):
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
# @version ^0.3.7


decano: address
estudiantes: HashMap[address, uint32]
dnis: DynArray[uint32, 30]

@external
def __init__():
    pass


@external
def establecerDuenio(decano:address):
    assert self.decano == 0x0000000000000000000000000000000000000000, "El decano de este contrato ya se encuentra establecido"
    self.decano = decano

@external
def inscribirEstudiante(dni: uint32, estudiante: address):
    assert self.estudiantes[estudiante] == 0, "Este estudiante ya se encuentra registrado"
    self.estudiantes[estudiante] = dni
    self.dnis.append(dni)

@external
def verInscriptos(decano:address) -> DynArray[uint32, 30]:
    assert self.decano == decano, "Solo el decano puede solicitar la lista de inscriptos"
    return self.dnis

@external
def destroy(decano:address):
    assert self.decano == decano, "Solo el decano puede solicitar la lista de inscriptos"
    selfdestruct(msg.sender)
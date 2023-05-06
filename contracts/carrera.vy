# @version ^0.3.7


decano: address
estudiantes: HashMap[address, uint32]
direcciones: address[30]
index: uint32

@external
def __init__():
    self.decano = msg.sender


@external
def inscribirEstudiante(dni: uint32):
    assert self.estudiantes[msg.sender] != 0, "Este estudiante ya se encuentra registrado"
    self.direcciones[self.index] = msg.sender
    self.index +=1
    self.estudiantes[msg.sender] = dni

@external
def viewShipment() -> uint32[30]:
    assert self.decano == msg.sender, "Solo el decano puede solicitar la lista de inscriptos"
    dnis: uint32[30] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    indice : uint32 = 0
    for  i in  self.direcciones:
        dnis[indice] =  self.estudiantes[i]
        indice +=1
    
    return dnis

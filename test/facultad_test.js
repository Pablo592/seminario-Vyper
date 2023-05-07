var shared = require("./shared");
const verifyThrows = shared.verifyThrows;

const Facultad = artifacts.require("Facultad");
const Carrera = artifacts.require("Carrera");
var costoCuota = costoCuota

contract("Facultad", (accounts) => {
    it("Debe poder crear una carrera", async () => {
        const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
        const CarreraInstance = await Carrera.deployed(accounts[0]);
        const resultado = await FacultadInstance.generarCarrera(CarreraInstance.address, 'Ingenieria en informatica', { from: accounts[0] });
        assert.equal(resultado.logs[0].event, "CarreraCreada", "Hubo un error al crear la carrera");
    });


    it('No deben existir dos carreras con el mismo nombre', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            const CarreraInstance = await Carrera.deployed(accounts[0]);
            await FacultadInstance.generarCarrera(CarreraInstance.address, 'Ingenieria en informatica', { from: accounts[0] });
        }, /Esta carrera ya se encuentra creada/);
    });

    it('El estudiante debe inscribirse antes de pagar su cuota', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.pagarInscripcion({ value: costoCuota, from: accounts[5] });
        }, /Este estudiante no se encuentra registrado/);
    });

    it('El estudiante debe inscribirse antes de presentar el analitico', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.resgistrarEstudianteAnalitico('0xc0673dc9624f8a0a5bc7e9f75d9dec603b78e700793d7284df203235e2277492', { from: accounts[1] });
        }, /Este estudiante no se encuentra registrado/);
    });

    it("Se debe poder registrar a un estudiante", async () => {
        const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
        const resultado = await FacultadInstance.resgistrarEstudiante('Pablo', 'Gaido', 42000000, { from: accounts[1] });
        assert.equal(resultado.logs[0].event, "EstudianteRegistrado", "Hubo un error al registrar al estudiante");
        assert.equal(resultado.logs[0].args.nombre.toString(), 'Pablo');
        assert.equal(resultado.logs[0].args.apellido.toString(), 'Gaido');
        assert.equal(resultado.logs[0].args.dni.toString(), '42000000');
    });

    it('El estudiante debe presentar su analitico antes de poder inscribirse a una carrera', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.inscribirEnCarrera('Ingenieria en informatica', { from: accounts[1] });
        }, /Este estudiante todavia no ha presentado su analitico/);
    });

    it("El estudiante debe poder presentar su analitico", async () => {
        let analitico = '0xc0673dc9624f8a0a5bc7e9f75d9dec603b78e700793d7284df203235e2277492'
        const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
        resultado = await FacultadInstance.resgistrarEstudianteAnalitico(analitico, { from: accounts[1] });
        assert.equal(resultado.logs[0].event, "EstudiantePresentaAnalitico", "El estudiante debe poder presentar su analitico");
        assert.equal(resultado.logs[0].args.analitico.toString(), analitico);
    });

    it('Se debe ingresar un monto correcto al pagar la inscripcion', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.pagarInscripcion({ value: 0, from: accounts[1] });
        }, /El monto ingresado no es el adecuado/);
    });

    it("Se debe poder pagar la inscripcion", async () => {
        const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
        resultado = await FacultadInstance.pagarInscripcion({ value: '1000', from: accounts[1] });
        assert.equal(resultado.logs[0].event, "MontoAPagar", "Hubo un error al pagar la inscripcion");
        assert.equal(resultado.logs[0].args.costoDeLaCuota.toString(), 1000);
    });

    it('No se debe pagar la inscripcion mas de una vez', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.pagarInscripcion({ value: '1000', from: accounts[1] });
        }, /Ya ha pagado la inscripcion/);
    });

    it("Un estudiante debe poder inscribirse a una carrera", async () => {
        const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
        resultado = await FacultadInstance.inscribirEnCarrera('Ingenieria en informatica', { from: accounts[1] });
        assert.equal(resultado.logs[0].event, "EstudianteInscriptoEnCarrera", "Hubo un error al inscribirse a la materia");
        assert.equal(resultado.logs[0].args.nombreCarrera.toString(), 'Ingenieria en informatica');
    });


    it('Solo el decano puede solicitar la lista de alumnos', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.estudiantesDeCarrera('Ingenieria en informatica',{from: accounts[1]});
        }, /Solo el decano puede llamar a esta funcion/);
    });


    it('Se debe solicitar la lista de alumnos de una carrera que exista', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.estudiantesDeCarrera('nada',{from: accounts[0]});
        }, /Esta carrera no se encuentra creada/);
    });

    it('Un estudiante no debe registrarse mas de una vez', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.resgistrarEstudiante('Pablo', 'Gaido', 42000000, { from: accounts[1] });
        }, /Este estudiante ya se encuentra registrado/);
    });

    it('El decano no puede ser estudiante', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.resgistrarEstudiante('Pablo', 'Gaido', 42000000, { from: accounts[0] });
        }, /El decano no puede ser estudiante/);
    });

    it('No se aceptan los DNI duplicados', async () => {
        await verifyThrows(async () => {
            const FacultadInstance = await Facultad.deployed(accounts[0], costoCuota);
            await FacultadInstance.resgistrarEstudiante('Pablo', 'Gaido', 42000000, { from: accounts[2] });
        }, /No se aceptan los DNI duplicados/);
    });
})
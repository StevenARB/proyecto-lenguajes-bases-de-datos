CREATE USER C##HospitalExpress IDENTIFIED BY hospitalexpress123 
DEFAULT TABLESPACE USERS 
TEMPORARY TABLESPACE TEMP 
QUOTA UNLIMITED ON USERS;

GRANT DBA TO C##HospitalExpress;










/*--------------------Usuarios--------------------*/
--TABLA Usuarios
CREATE TABLE C##HospitalExpress.Usuarios (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR2(255) UNIQUE,
    password VARCHAR2(255),
    rol VARCHAR2(25),
    estado VARCHAR2(25)
);

--CRUD Usuarios
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_USUARIO (
    p_email IN VARCHAR2,
    p_password IN VARCHAR2,
    p_rol IN VARCHAR2,
    p_estado IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    INSERT INTO
        usuarios (email, password, rol, estado)
    VALUES
        (
            p_email,
            p_password,
            p_rol,
            p_estado
        );
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_USUARIOS (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM usuarios ORDER BY id_usuario ASC;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron usuarios';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_USUARIO_ID (
    p_id_usuario IN INTEGER,
    p_email OUT VARCHAR2,
    p_password OUT VARCHAR2,
    p_rol OUT VARCHAR2,
    p_estado OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT email, password, rol, estado
    INTO p_email, p_password, p_rol, p_estado
    FROM usuarios
    WHERE id_usuario = p_id_usuario;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Usuario no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_USUARIO_EMAIL (
    p_email IN VARCHAR2,
    p_id_usuario OUT INTEGER,
    p_rol OUT VARCHAR2,
    p_estado OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT id_usuario, rol, estado
    INTO p_id_usuario, p_rol, p_estado
    FROM usuarios
    WHERE email = p_email;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Usuario no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_USUARIO (
    p_id_usuario IN INTEGER,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2,
    p_rol IN VARCHAR2,
    p_estado IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    UPDATE usuarios
    SET email = p_email,
        password = p_password,
        rol = p_rol,
        estado = p_estado
    WHERE id_usuario = p_id_usuario;

    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Usuario actualizado exitosamente';
    ELSE
        p_resultado := 'ERROR: Usuario no encontrado para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_USUARIO (
    p_email IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    DELETE FROM usuarios
    WHERE email = p_email;

    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Usuario eliminado exitosamente';
    ELSE
        p_resultado := 'ERROR: Usuario no encontrado para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_USUARIO_PACIENTE (
    p_email IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
    v_id_usuario INTEGER;
    
    CURSOR c_usuario IS
        SELECT id_usuario
        FROM usuarios
        WHERE email = p_email;
BEGIN
    --Se obtiene el Id del Usuario mediante un Cursor
    OPEN c_usuario;
    FETCH c_usuario INTO v_id_usuario;
    CLOSE c_usuario;

    IF v_id_usuario IS NOT NULL THEN
        DELETE FROM C##HospitalExpress.Pacientes
        WHERE id_usuario = v_id_usuario;

        DELETE FROM usuarios
        WHERE email = p_email;

        p_resultado := 'EXITO: Usuario y paciente asociado eliminados exitosamente';
    ELSE
        p_resultado := 'ERROR: Usuario no encontrado para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--VISTA Usuarios
CREATE VIEW C##HospitalExpress.VISTA_USUARIOS AS
SELECT id_usuario, email, password, rol, estado
FROM C##HospitalExpress.Usuarios;

--FUNCIONES Usuarios
CREATE OR REPLACE FUNCTION C##HospitalExpress.GET_NUMERO_USUARIOS RETURN INTEGER
AS
    v_numero_usuarios INTEGER;
    CURSOR v_numero_usuarios_cursor IS
        SELECT COUNT(*) AS numero_usuarios
        FROM VISTA_USUARIOS
        WHERE Estado = 'Activo';
BEGIN
    OPEN v_numero_usuarios_cursor;
    FETCH v_numero_usuarios_cursor INTO v_numero_usuarios;
    CLOSE v_numero_usuarios_cursor;

    RETURN v_numero_usuarios;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_GET_NUMERO_USUARIOS (
    p_resultado OUT INTEGER
)
AS 
BEGIN
    p_resultado := GET_NUMERO_USUARIOS;

    IF p_resultado = -1 THEN
        p_resultado := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 0;
END;









/*--------------------Pacientes--------------------*/
--TABLA Pacientes
CREATE TABLE C##HospitalExpress.Pacientes (
    id_paciente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    primer_apellido VARCHAR2(50) NOT NULL,
    segundo_apellido VARCHAR2(50) NOT NULL,
    email VARCHAR2(255) NOT NULL UNIQUE,
    direccion VARCHAR2(255) NOT NULL,
    genero VARCHAR2(50) NOT NULL,
    fecha_nac DATE NOT NULL,
    id_usuario INTEGER,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

--CRUD Pacientes
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_PACIENTE (
    p_nombre IN VARCHAR2,
    p_primer_apellido IN VARCHAR2,
    p_segundo_apellido IN VARCHAR2,
    p_email IN VARCHAR2,
    p_direccion IN VARCHAR2,
    p_genero IN VARCHAR2,
    p_fecha_nac IN VARCHAR2,
    p_resultado OUT VARCHAR2
)
AS 
BEGIN
    INSERT INTO
        pacientes (nombre, primer_apellido, segundo_apellido, email, direccion, genero, fecha_nac)
    VALUES
        (
            p_nombre,
            p_primer_apellido,
            p_segundo_apellido,
            p_email,
            p_direccion,
            p_genero,
            TO_DATE(p_fecha_nac, 'YYYY-MM-DD')
        );
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_PACIENTE_ID (
    p_id_paciente IN INTEGER,
    p_nombre OUT VARCHAR2,
    p_primer_apellido OUT VARCHAR2,
    p_segundo_apellido OUT VARCHAR2,
    p_email OUT VARCHAR2,
    p_direccion OUT VARCHAR2,
    p_genero OUT VARCHAR2,
    p_fecha_nac OUT DATE,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT nombre, primer_apellido, segundo_apellido, email, direccion, genero, fecha_nac
    INTO p_nombre, p_primer_apellido, p_segundo_apellido, p_email, p_direccion, p_genero, p_fecha_nac
    FROM pacientes
    WHERE id_paciente = p_id_paciente;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Paciente no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_PACIENTES (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM pacientes ORDER BY id_paciente ASC;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron pacientes';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_PACIENTE (
    p_id_paciente IN INTEGER,
    p_nombre IN VARCHAR2,
    p_primer_apellido IN VARCHAR2,
    p_segundo_apellido IN VARCHAR2,
    p_email IN VARCHAR2,
    p_direccion IN VARCHAR2,
    p_genero IN VARCHAR2,
    p_fecha_nac IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    UPDATE pacientes
    SET nombre = p_nombre,
        primer_apellido = p_primer_apellido,
        segundo_apellido = p_segundo_apellido,
        email = p_email,
        direccion = p_direccion,
        genero = p_genero,
        fecha_nac = TO_DATE(p_fecha_nac, 'YYYY-MM-DD')
    WHERE id_paciente = p_id_paciente;

    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Paciente actualizado exitosamente';
    ELSE
        p_resultado := 'ERROR: Paciente no encontrado para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_PACIENTE (
    p_email IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    DELETE FROM C##HospitalExpress.Pacientes
    WHERE email = p_email;
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Paciente eliminado exitosamente';
    ELSE
        p_resultado := 'ERROR: Paciente no encontrado para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--VISTA Pacientes
CREATE OR REPLACE VIEW C##HospitalExpress.VISTA_PACIENTES AS
SELECT
  id_paciente,
  nombre,
  primer_apellido,
  segundo_apellido,
  email,
  direccion,
  genero,
  fecha_nac,
  id_usuario
FROM
  C##HospitalExpress.Pacientes;

--FUNCIONES Pacientes
CREATE OR REPLACE FUNCTION C##HospitalExpress.GET_NUMERO_PACIENTES RETURN INTEGER
AS
    v_numero_pacientes INTEGER;
    CURSOR v_numero_pacientes_cursor IS
        SELECT COUNT(*) AS numero_pacientes
        FROM VISTA_PACIENTES;
BEGIN
    OPEN v_numero_pacientes_cursor;
    FETCH v_numero_pacientes_cursor INTO v_numero_pacientes;
    CLOSE v_numero_pacientes_cursor;

    RETURN v_numero_pacientes;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_GET_NUMERO_PACIENTES (
    p_resultado OUT INTEGER
)
AS 
BEGIN
    p_resultado := GET_NUMERO_PACIENTES;

    IF p_resultado = -1 THEN
        p_resultado := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 0;
END;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_PACIENTES
BEFORE INSERT ON C##HospitalExpress.Pacientes
FOR EACH ROW
DECLARE
    v_id_usuario INTEGER;
    v_rol VARCHAR2(25);
    v_estado VARCHAR2(25);
    v_resultado VARCHAR2(50);
BEGIN
    C##HospitalExpress.SP_CONSULTAR_USUARIO_EMAIL(:NEW.email, v_id_usuario, v_rol, v_estado, v_resultado);
    CASE
        WHEN v_resultado = 'EXITO' THEN
            :NEW.id_usuario := v_id_usuario;
        WHEN v_resultado = 'ERROR: Usuario no encontrado' THEN
            INSERT INTO C##HospitalExpress.Usuarios (email, password, rol, estado)
            VALUES (:NEW.email, NULL, 'Paciente', 'Activo')
            RETURNING id_usuario INTO :NEW.id_usuario;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Error al consultar el usuario: ' || v_resultado);
    END CASE;
END;

CREATE OR REPLACE TRIGGER TRG_BEFORE_UPDATE_PACIENTES
BEFORE UPDATE ON C##HospitalExpress.Pacientes
FOR EACH ROW
DECLARE
    v_id_usuario INTEGER;
    v_rol VARCHAR2(25);
    v_estado VARCHAR2(25);
    v_resultado VARCHAR2(50);
BEGIN
    C##HospitalExpress.SP_CONSULTAR_USUARIO_EMAIL(:NEW.email, v_id_usuario, v_rol, v_estado, v_resultado);
    CASE
        WHEN v_resultado = 'EXITO' THEN
            :NEW.id_usuario := v_id_usuario;
        WHEN v_resultado = 'ERROR: Usuario no encontrado' THEN
            INSERT INTO C##HospitalExpress.Usuarios (email, password, rol, estado)
            VALUES (:NEW.email, NULL, 'Paciente', 'Activo')
            RETURNING id_usuario INTO :NEW.id_usuario;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Error al consultar el usuario: ' || v_resultado);
    END CASE;
END;












/*--------------------Doctores--------------------*/
--TABLA Doctor
CREATE TABLE C##HospitalExpress.Doctor(
    id_doctor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(250),
    direccion VARCHAR(250),
    telefono VARCHAR(250),
    estado VARCHAR2(25)
);

--CRUD Doctor
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_DOCTOR (
    d_nombre IN VARCHAR2,
    d_direccion IN VARCHAR2,
    d_telefono IN VARCHAR2,
    d_estado IN VARCHAR2,
    d_resultado OUT VARCHAR2
) AS
BEGIN
    INSERT INTO Doctor (nombre, direccion, telefono, estado)
    VALUES (d_nombre, d_direccion, d_telefono, d_estado);

    d_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        d_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_DOCTOR(
    d_id_doctor IN INT,
    d_nombre OUT VARCHAR2,
    d_direccion OUT VARCHAR2,
    d_telefono OUT VARCHAR2,
    d_estado OUT VARCHAR2,
    d_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT nombre, direccion, telefono, estado
    INTO d_nombre, d_direccion, d_telefono, d_estado
    FROM Doctor
    WHERE id_doctor = d_id_doctor;

    d_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        d_resultado := 'ERROR: Doctor no encontrado';
    WHEN OTHERS THEN
        d_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_DOCTORES (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM C##HospitalExpress.Doctor;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron doctores';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SP_OBTENER_DOCTOR_POR_ID(
    d_id IN INT
)
IS
    d_id_doctor INT;
    d_nombre VARCHAR2(50);
    d_telefono VARCHAR2(55);
    d_estado VARCHAR2(50);

    -- Declarar el cursor
    CURSOR cursor_Doctor IS
        SELECT id_doctor, nombre, telefono, estado 
        FROM C##HospitalExpress.Doctor
        WHERE id_doctor = d_id;
BEGIN
    OPEN cursor_Doctor;

    FETCH cursor_Doctor INTO d_id_doctor, d_nombre, d_telefono, d_estado;

    IF cursor_Doctor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID: ' || TO_CHAR(d_id_doctor) || ', Nombre: ' || d_nombre 
        || ', Telefono: ' || d_telefono || ', Estado: ' || d_estado);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró el doctor con el ID: ' || TO_CHAR(d_id));
    END IF;
    CLOSE cursor_Doctor;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_DOCTOR (
    d_id IN INT,
    d_nombre IN VARCHAR2,
    d_direccion IN VARCHAR2,
    d_telefono IN VARCHAR2,
    d_estado IN VARCHAR2,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    UPDATE Doctor
    SET nombre = d_nombre,
        direccion = d_direccion,
        telefono = d_telefono,
        estado = d_estado
    WHERE id_doctor = d_id;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Doctor actualizado exitosamente';
    ELSE
        p_resultado := 'ERROR: Doctor no encontrado para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_DOCTOR (
    d_id IN INT,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    DELETE FROM Doctor WHERE id_doctor = d_id;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Doctor eliminado exitosamente';
    ELSE
        p_resultado := 'ERROR: Doctor no encontrado para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

----------------------TRIGGER DOCTOR
CREATE OR REPLACE TRIGGER TRG_BEFORE_DELETE_DOCTOR
BEFORE DELETE ON C##HospitalExpress.Doctor
FOR EACH ROW
BEGIN
    IF :OLD.estado = 'Activo' THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede eliminar un doctor activo. Desactivar primero.');
    END IF;
END;

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_TELEFONO_FORMATO
BEFORE INSERT OR UPDATE ON C##HospitalExpress.Doctor
FOR EACH ROW
BEGIN
    IF REGEXP_LIKE(:NEW.telefono, '^[0-9-]{1,}$') = FALSE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: El formato del número de teléfono no es válido. Debe contener solo dígitos y el carácter "-".');
    END IF;
END;


--VISTA DE DOCTORES
CREATE OR REPLACE VIEW VISTA_DOCTORES AS
SELECT
    id_doctor,
    nombre,
    direccion,
    telefono,
    estado
FROM
    doctor;

--STORED PROCEDURES DE DOCTORES
CREATE OR REPLACE PROCEDURE SP_OBTENER_DOCTORES_ESTADO (
    d_estado_doctor IN VARCHAR2
) AS
    d_id INT;
    d_nombre VARCHAR2(50);
    d_estado VARCHAR2(10);

    CURSOR c_doctores IS
        SELECT ID_DOCTOR, NOMBRE, ESTADO FROM C##HospitalExpress.Doctor
        WHERE estado = d_estado_doctor;
BEGIN
    OPEN c_doctores;
    
    LOOP 
    FETCH c_doctores INTO d_id, d_nombre, d_estado;
    EXIT WHEN c_doctores%NOTFOUND;
    
    DBMS_OUTPUT.PUT_LINE('ID: ' || d_id || ' Nombre' || d_nombre ||
    ' Estado: '|| d_estado);
    END LOOP;
    CLOSE c_doctores;
END;

CREATE OR REPLACE PROCEDURE SP_CAMBIAR_ESTADO_DOCTOR (
    d_id IN INT,
    d_nuevo_estado IN VARCHAR2
) AS
BEGIN
    UPDATE C##HospitalExpress.Doctor
    SET estado = d_nuevo_estado
    WHERE id_doctor = d_id;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE SP_OBTENER_CANTIDAD_DOCTORES_POR_ESTADO (
    d_estado IN VARCHAR2,
    d_cantidad OUT INT
) AS
BEGIN
    SELECT COUNT(*) INTO d_cantidad
    FROM C##HospitalExpress.Doctor
    WHERE estado = d_estado;
END;

--FUNCIONES Doctor
CREATE OR REPLACE FUNCTION C##HospitalExpress.GET_NUMERO_DOCTORES RETURN INTEGER
AS
    v_numero_doctores INTEGER;
    CURSOR v_numero_doctores_cursor IS
        SELECT COUNT(*) AS numero_doctores
        FROM VISTA_DOCTORES
        WHERE estado = 'Activo';
BEGIN
    OPEN v_numero_doctores_cursor;
    FETCH v_numero_doctores_cursor INTO v_numero_doctores;
    CLOSE v_numero_doctores_cursor;

    RETURN v_numero_doctores;
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_GET_NUMERO_DOCTORES (
    p_resultado OUT INTEGER
)
AS 
BEGIN
    p_resultado := GET_NUMERO_DOCTORES;

    IF p_resultado = -1 THEN
        p_resultado := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 0;
END;
    








/*--------------------Especialidades--------------------*/
--TABLA Especialidades
CREATE TABLE Especialidades(
    id_especialidad INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR2(100),
    descripcion VARCHAR2(255)
);

--CRUD Especialidades
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_ESPECIALIDAD (
    p_nombre  IN VARCHAR2,
    p_descripcion  IN VARCHAR2,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    INSERT INTO Especialidades (nombre, descripcion)
    VALUES (p_nombre, p_descripcion);
    
    COMMIT;
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_ESPECIALIDAD (
    p_id_especialidad IN INT,
    p_nombre OUT VARCHAR2,
    p_descripcion OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT nombre, descripcion
    INTO p_nombre, p_descripcion
    FROM Especialidades
    WHERE id_especialidad = p_id_especialidad;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Especialidad no encontrada';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_ESPECIALIDADES (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM C##HospitalExpress.Especialidades;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron especialidades';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_ESPECIALIDAD (
    p_id_especialidad IN NUMBER,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    UPDATE Especialidades
    SET nombre = p_nombre,
        descripcion = p_descripcion
    WHERE id_especialidad = p_id_especialidad;
    
    COMMIT;
    p_resultado := 'EXITO: Especialidad actualizada exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_ESPECIALIDAD (
    p_id_especialidad IN NUMBER,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    -- Eliminar de especialidades
    DELETE FROM Especialidades WHERE id_especialidad = p_id_especialidad;
    
    COMMIT;
    p_resultado := 'EXITO: Especialidad eliminada exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;









/*--------------------Doctores y Especialidades--------------------*/
--TABLA Doctores y Especialidades
CREATE TABLE doctores_especialidades (
    id_doctor INTEGER,
    id_especialidad INTEGER,
    PRIMARY KEY (id_doctor, id_especialidad),
    FOREIGN KEY (id_doctor) REFERENCES C##HospitalExpress.Doctor(id_doctor),
    FOREIGN KEY (id_especialidad) REFERENCES Especialidades(id_especialidad)
);

--CRUD Doctores y Especialidades
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_DOCTOR_ESPECIALIDAD (
    p_id_doctor  IN INTEGER,
    p_id_especialidad  IN INTEGER,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    -- Insertar en doctores_especialidades
    INSERT INTO doctores_especialidades (id_doctor, id_especialidad)
    VALUES (p_id_doctor, p_id_especialidad);
    
    COMMIT;
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_DOCTOR_ESPECIALIDAD (
    p_id_doctor IN INTEGER,
    p_id_especialidad IN INTEGER,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT 1
    INTO p_resultado
    FROM doctores_especialidades
    WHERE id_doctor = p_id_doctor AND id_especialidad = p_id_especialidad;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Relación doctor-especialidad no encontrada';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_DOCTOR_ESPECIALIDAD (
    p_id_doctor IN INTEGER,
    p_id_especialidad IN INTEGER,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    DELETE FROM doctores_especialidades
    WHERE id_doctor = p_id_doctor AND id_especialidad = p_id_especialidad;
    
    COMMIT;
    p_resultado := 'EXITO: Doctor-Especialidad eliminada exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--FUNCIONES Doctores y Especialidades
CREATE OR REPLACE FUNCTION FN_CONTAR_DOCTORES_ESPECIALIDAD (
    d_id_especialidad INT
) RETURN INT AS 
    v_cantidad INT;
BEGIN
    SELECT COUNT(*)
    INTO v_cantidad
    FROM doctores_especialidades
    WHERE id_especialidad = d_id_especialidad;
    
    RETURN v_cantidad;
END;










/*--------------------Citas--------------------*/
--TABLA Cita
CREATE TABLE C##HospitalExpress.Cita (
    id_cita INTEGER PRIMARY KEY,
    id_doctor INTEGER,
    id_paciente INTEGER,
    tipo VARCHAR(100),
    fecha_hora DATE,
    estado VARCHAR(100),
    FOREIGN KEY (id_doctor) REFERENCES C##HospitalExpress.Doctor(id_doctor),
    FOREIGN KEY (id_paciente) REFERENCES C##HospitalExpress.Pacientes(id_paciente)
);

--CRUD Cita
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_CITA (
    p_id_paciente IN INTEGER,
    p_tipo IN VARCHAR2,
    p_fecha_hora IN DATE,
    p_estado IN VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    INSERT INTO
        Cita (id_paciente, tipo, fecha_hora, estado)
    VALUES
        (
            p_id_paciente,
            p_tipo,
            p_fecha_hora,
            p_estado
        );
    p_resultado := 'Nueva Cita Ingresada';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_CITA (
    p_id_cita IN INTEGER,
    p_tipo OUT VARCHAR2,
    p_fecha_hora OUT VARCHAR2,
    p_estado OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT tipo, fecha_hora, estado
    INTO p_tipo, p_fecha_hora, p_estado
    FROM Cita
    WHERE id_cita = p_id_cita;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: La cita ' || p_id_cita || ' no fue encontrada.';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_CITA (
    p_id_cita IN INTEGER,
    p_nueva_fecha_hora IN VARCHAR2,
    p_nuevo_estado IN VARCHAR2,
    p_resultado OUT VARCHAR2 /**parametro de salida**/
) 
AS 
BEGIN
    UPDATE Cita
    SET fecha_hora = p_nueva_fecha_hora,
        estado = p_nuevo_estado
    WHERE id_cita = p_id_cita;

    p_resultado := 'Cita Actualizada';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: La cita ' || p_id_cita || ' no fue encontrada en el sistema.';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_CITA (
    p_id_cita IN INTEGER,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    DELETE FROM Cita
    WHERE id_cita = p_id_cita;

    p_resultado := 'Cita eliminada con �xito';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: La cita ' || p_id_cita || ' no fue encontrada.';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--VISTA Cita
CREATE OR REPLACE VIEW Vista_Cita AS
SELECT
    id_cita,
    id_doctor,
    id_paciente,
    tipo,
    fecha_hora,
    estado
FROM
    Cita;

--CURSOR CITA
CREATE OR REPLACE PROCEDURE CONSULTAR_CITA(
    c_id IN NUMBER
)
IS
    -- Declarar el cursor antes del bloque BEGIN
    CURSOR cs_cita IS
        SELECT id_cita, id_doctor, id_paciente, tipo, fecha_hora, estado 
        FROM C##HospitalExpress.Cita
        WHERE id_cita = c_id;
    
    c_id_cita      C##HospitalExpress.Cita.ID_CITA%TYPE;
    c_id_doctor    C##HospitalExpress.Cita.ID_DOCTOR%TYPE;
    c_id_paciente  C##HospitalExpress.Cita.ID_PACIENTE%TYPE;
    c_tipo         C##HospitalExpress.Cita.TIPO%TYPE;
    c_fecha_hora   C##HospitalExpress.Cita.FECHA_HORA%TYPE;
    c_estado       C##HospitalExpress.Cita.ESTADO%TYPE;
BEGIN
    -- Utilizar el cursor declarado
    OPEN cs_cita;

    FETCH cs_cita INTO c_id_cita, c_id_doctor, c_id_paciente, c_tipo, c_fecha_hora, c_estado;

    IF cs_cita%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ID_CITA: ' || TO_CHAR(c_id_cita) || ', ID_DOCTOR: ' || TO_CHAR(c_id_doctor) 
        || ', ID_PACIENTE: ' || TO_CHAR(c_id_paciente) || ', TIPO: ' || c_tipo 
        || ', FECHA_HORA: ' || TO_CHAR(c_fecha_hora) || ', ESTADO: ' || c_estado);
    ELSE
        DBMS_OUTPUT.PUT_LINE('La cita: ' || TO_CHAR(c_id) || ' no fue encontrada.');
    END IF;
    CLOSE cs_cita;
END CONSULTAR_CITA;










/*--------------------Productos--------------------*/
--TABLA Productos
CREATE TABLE C##HospitalExpress.Productos (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255),
    Cantidad INT,
    Precio DECIMAL(10, 2)
);

--CRUD Productos
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_PRODUCTOS (
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_cantidad IN NUMBER,
    p_precio IN DECIMAL,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    INSERT INTO Productos ( Nombre, Descripcion, Cantidad, Precio)
    VALUES (p_nombre, p_descripcion, p_cantidad, p_precio);
 
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_PRODUCTO(
    p_id_producto IN INT,
    p_nombre OUT VARCHAR2,
    p_descripcion OUT VARCHAR2,
    p_cantidad OUT VARCHAR2,
    p_precio OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT Nombre, Descripcion, Cantidad, Precio
    INTO p_nombre, p_descripcion, p_cantidad, p_precio
    FROM Productos
    WHERE id_producto = p_id_producto;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Producto no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;


CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_PRODUCTO_ID (
    p_id_producto IN INTEGER,
    p_nombre OUT VARCHAR2,
    p_descripcion OUT VARCHAR2,
    p_cantidad OUT INT,
    p_precio OUT DECIMAL,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT Nombre, Descripcion, Cantidad, Precio
    INTO p_nombre, p_descripcion, p_cantidad, p_precio
    FROM Productos
    WHERE id_producto = p_id_producto;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Producto no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_PRODUCTOS (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM C##HospitalExpress.Productos ORDER BY id_producto ASC;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron productos';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_PRODUCTOS (
    p_id_producto IN INT,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_cantidad IN INT,
    p_precio IN DECIMAL,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    UPDATE Productos
    SET Nombre = p_nombre,
        Descripcion = p_descripcion,
        Cantidad = p_cantidad,
        Precio = p_precio
    WHERE id_producto = p_id_producto;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Producto actualizado exitosamente';
    ELSE
        p_resultado := 'ERROR: Producto no encontrado para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_PRODUCTOS (
    p_id_producto IN INT,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    DELETE FROM Productos WHERE id_producto = p_id_producto;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Producto eliminado exitosamente';
    ELSE
        p_resultado := 'ERROR: Producto no encontrado para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--VISTA DE PROCUTOS
CREATE OR REPLACE VIEW VISTAS_PRODUCTOS 
AS
SELECT 
    id_producto,
    nombre,
    descripcion,
    cantidad,
    precio
FROM
    PRODUCTOS;


----TRIGGER PRODUCTOS

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_CANTIDAD_PRODUCTO
BEFORE INSERT OR UPDATE ON C##HospitalExpress.Productos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad < 50 THEN
        RAISE_APPLICATION_ERROR(-20012, 'No se puede insertar o actualizar un producto con una cantidad inferior a 50.');
    END IF;
END;


CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_NEW_PRODUCTO
BEFORE INSERT OR UPDATE ON C##HospitalExpress.Productos
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM C##HospitalExpress.Productos
    WHERE UPPER(Nombre) = UPPER(:NEW.Nombre);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ya existe un producto con el mismo nombre.');
    END IF;
END;


CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_PRICE_PRODUCTO
BEFORE INSERT OR UPDATE ON C##HospitalExpress.Productos
FOR EACH ROW
BEGIN
    IF :NEW.Precio <= 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El precio del producto debe ser mayor a 1 dolare(s).');
    END IF;
END; 



--CURSOR
CREATE OR REPLACE PROCEDURE SP_Obtener_Productos_Precio (
    p_precio_maximo IN DECIMAL
)
AS
    p_id_producto Productos.id_producto%TYPE;
    p_nombre VARCHAR2(100);
    p_descripcion VARCHAR2(255);
    p_cantidad INT;
    p_precio Productos.Precio%TYPE;

    CURSOR cursorProductos IS
        SELECT id_producto, Nombre, Descripcion, Cantidad, Precio
        FROM Productos
        WHERE Precio <= p_precio_maximo;

BEGIN
    OPEN cursorProductos;
    DBMS_OUTPUT.PUT_LINE('Productos con precio menor o igual a ' || TO_CHAR(p_precio_maximo) || ':');
    LOOP
        FETCH cursorProductos INTO p_id_producto, p_nombre, p_descripcion, p_cantidad, p_precio;
        EXIT WHEN cursorProductos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || TO_CHAR(p_id_producto) || ', Nombre: ' || p_nombre ||
                             ', Descripción: ' || p_descripcion || ', Cantidad: ' || TO_CHAR(p_cantidad) ||
                             ', Precio: ' || TO_CHAR(p_precio));
    END LOOP;

    CLOSE cursorProductos;

END;

--STORED PROCEDURE
CREATE OR REPLACE PROCEDURE SP_Buscar_Productos_Nombre(
    p_nombre_in IN productos.nombre%TYPE
)
IS
    p_id_producto INT;
    p_nombre_producto VARCHAR2(255);
    p_descripcion VARCHAR2(255);
    p_cantidad INT;
    p_precio productos.precio%TYPE;

    CURSOR cursorProductos IS
        SELECT id_producto, nombre, descripcion, cantidad, precio
        FROM productos
        WHERE LOWER(nombre) LIKE '%' || LOWER(p_nombre_in) || '%';

BEGIN
    OPEN cursorProductos;

    DBMS_OUTPUT.PUT_LINE('Productos con nombres que contienen "' || p_nombre_in || '":');
    LOOP
        FETCH cursorProductos INTO p_id_producto, p_nombre_producto, p_descripcion, p_cantidad, p_precio;
        EXIT WHEN cursorProductos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID: ' || TO_CHAR(p_id_producto) || ', Nombre: ' || p_nombre_producto ||
                             ', Descripción: ' || p_descripcion || ', Cantidad: ' || TO_CHAR(p_cantidad) ||
                             ', Precio: ' || TO_CHAR(p_precio));
    END LOOP;
    CLOSE cursorProductos;
END;

--FUNCION DE PRODUCTOS
CREATE OR REPLACE FUNCTION FN_OBTENER_PRECIO_PROMEDIO 
RETURN DECIMAL IS p_precio_promedio DECIMAL;
BEGIN
    SELECT AVG(precio) INTO p_precio_promedio 
    FROM PRODUCTOS;
    RETURN p_precio_promedio;
END;










/*--------------------Medicamentos--------------------*/
--TABLA Medicamentos
CREATE TABLE C##HospitalExpress.Medicamentos (
    id_medicamento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Dosis VARCHAR(50),
    Cantidad INT,
    Precio DECIMAL(10, 2)
);

--CRUD Medicamentos
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_MEDICAMENTO (
    p_nombre IN VARCHAR2,
    p_dosis IN VARCHAR2,
    p_cantidad IN INT,
    p_precio IN DECIMAL,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    INSERT INTO Medicamentos (Nombre, Dosis, Cantidad, Precio)
    VALUES (p_nombre, p_dosis, p_cantidad, p_precio);

    p_resultado := 'EXITO: Medicamento insertado exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END SP_INSERTAR_MEDICAMENTO;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_MEDICAMENTO(
    p_id_medicamento IN INT,
    p_nombre OUT VARCHAR2,
    p_dosis OUT VARCHAR2,
    p_cantidad OUT INT,
    p_precio OUT DECIMAL,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT nombre, dosis, cantidad, precio
    INTO p_nombre, p_dosis, p_cantidad, p_precio
    FROM Medicamentos
    WHERE id_medicamento = p_id_medicamento;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Medicamento no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END SP_CONSULTAR_MEDICAMENTO;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_MEDICAMENTOS (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM C##HospitalExpress.Medicamentos ORDER BY id_medicamento ASC;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron medicamentos';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_MEDICAMENTO (
    p_id_medicamento IN INT,
    p_nombre IN VARCHAR2,
    p_dosis IN VARCHAR2,
    p_cantidad IN INT,
    p_precio IN DECIMAL,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    UPDATE Medicamentos
    SET nombre = p_nombre,
        dosis = p_dosis,
        cantidad = p_cantidad,
        precio = p_precio
    WHERE id_medicamento = p_id_medicamento ;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Medicamento actualizado exitosamente';
    ELSE
        p_resultado := 'ERROR: Medicamento no encontrado para actualizar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END SP_ACTUALIZAR_MEDICAMENTO;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_MEDICAMENTO (
    p_id_medicamento IN INT,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    DELETE FROM Medicamentos
    WHERE id_medicamento = p_id_medicamento;

    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Medicamento eliminado exitosamente';
    ELSE
        p_resultado := 'ERROR: No se encontró ningún medicamento con el ID ' || p_id_medicamento;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END SP_ELIMINAR_MEDICAMENTO;


----------------Triggers

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_PRICE_MEDICAMENTO
BEFORE INSERT OR UPDATE ON C##HospitalExpress.Medicamentos
FOR EACH ROW
BEGIN
    IF :NEW.Precio <= 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El precio del medicamento debe ser mayor a 1 dolare(s).');
    END IF;
END; 


/*--------------------Facturas--------------------*/
--TABLA Facturas
CREATE TABLE C##HospitalExpress.Facturas (
    id_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    id_paciente INTEGER NOT NULL,
    total DECIMAL(18,2) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
);

--CRUD Facturas
--CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_FACTURA (
    p_id_paciente IN INTEGER,
    p_total IN DECIMAL,
    p_fecha_hora IN TIMESTAMP,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    INSERT INTO
        Facturas (id_paciente, total, fecha_hora)
    VALUES
        (
            p_id_paciente,
            p_total,
            p_fecha_hora
        );
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_FACTURA (
    p_id_factura IN INTEGER,
    p_id_paciente OUT INTEGER,
    p_total OUT DECIMAL,
    p_fecha_hora OUT TIMESTAMP,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT id_paciente, total, fecha_hora
    INTO p_id_paciente, p_total, p_fecha_hora
    FROM Facturas
    WHERE id_factura = p_id_factura;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: La factura ' || p_id_factura || ' no fue encontrada.';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_FACTURA (
    p_id_factura IN INTEGER,
    p_nuevo_total IN DECIMAL,
    p_nueva_fecha_hora IN TIMESTAMP,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    UPDATE Facturas
    SET total = p_nuevo_total,
        fecha_hora = p_nueva_fecha_hora
    WHERE id_factura = p_id_factura;

    p_resultado := 'Factura Actualizada';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: La factura ' || p_id_factura || ' no fue encontrada en el sistema';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_FACTURA (
    p_id_factura IN INTEGER,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    DELETE FROM Facturas
    WHERE id_factura = p_id_factura;
    
    IF SQL%ROWCOUNT > 0 THEN
        p_resultado := 'EXITO: Factura eliminada exitosamente';
    ELSE
        p_resultado := 'ERROR: Factura no encontrada para eliminar';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_FACTURAS_PACIENTE (
    p_id_paciente IN INTEGER,
    p_resultado OUT VARCHAR2
) 
AS 
    CURSOR c_facturas IS
        SELECT id_factura
        FROM Facturas
        WHERE id_paciente = p_id_paciente;
    v_id_factura INTEGER;
BEGIN
    OPEN c_facturas;
    LOOP
        FETCH c_facturas INTO v_id_factura;
        EXIT WHEN c_facturas%NOTFOUND;

        DELETE FROM Facturas
        WHERE id_factura = v_id_factura;
    END LOOP;
    CLOSE c_facturas;

    DELETE FROM Pacientes
    WHERE id_paciente = p_id_paciente;

    p_resultado := 'Facturas y Paciente eliminados con �xito';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: El paciente con ID ' || p_id_paciente || ' no fue encontrado en el sistema.';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

--VISTAS Facturas
CREATE OR REPLACE VIEW Vista_Pacientes_Facturas AS
SELECT
    p.id_paciente,
    p.nombre,
    f.id_factura,
    f.total
FROM
    Pacientes p
JOIN
    Facturas f ON p.id_paciente = f.id_paciente;

--FUNCIONES Facturas
CREATE OR REPLACE FUNCTION GET_GANANCIONES_TOTALES RETURN DECIMAL
IS
    ganancias_totales DECIMAL(18, 2);
BEGIN
    SELECT
        SUM(total)
    INTO
        ganancias_totales
    FROM
        Facturas;

    RETURN ganancias_totales;
END;




/*--------------------Tratamientos--------------------*/

--TABLA Tratamientos
CREATE TABLE Tratamientos (
    id_tratamiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(255) NOT NULL
);

-- CREATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_INSERTAR_TRATAMIENTO (
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    INSERT INTO Tratamientos (nombre, descripcion)
    VALUES (p_nombre, p_descripcion);
    
    COMMIT;
    p_resultado := 'EXITO';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

-- READ
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_TRATAMIENTO (
    p_id_tratamiento IN INT,
    p_nombre OUT VARCHAR2,
    p_descripcion OUT VARCHAR2,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    SELECT nombre, descripcion
    INTO p_nombre, p_descripcion
    FROM Tratamientos
    WHERE id_tratamiento = p_id_tratamiento;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: Tratamiento no encontrado';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_CONSULTAR_TRATAMIENTOS (
    p_cursor OUT SYS_REFCURSOR,
    p_resultado OUT VARCHAR2
) 
AS 
BEGIN
    OPEN p_cursor FOR
        SELECT * FROM C##HospitalExpress.Tratamientos;

    p_resultado := 'EXITO';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 'ERROR: No se encontraron tratamientos';
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

-- UPDATE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ACTUALIZAR_TRATAMIENTO (
    p_id_tratamiento IN NUMBER,
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    UPDATE Tratamientos
    SET nombre = p_nombre,
        descripcion = p_descripcion
    WHERE id_tratamiento = p_id_tratamiento;
    
    COMMIT;
    p_resultado := 'EXITO: Tratamiento actualizado exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

-- DELETE
CREATE OR REPLACE PROCEDURE C##HospitalExpress.SP_ELIMINAR_TRATAMIENTO (
    p_id_tratamiento IN NUMBER,
    p_resultado OUT VARCHAR2
)
AS
BEGIN
    -- Eliminar de tratamientos
    DELETE FROM Tratamientos WHERE id_tratamiento = p_id_tratamiento;
    
    COMMIT;
    p_resultado := 'EXITO: Tratamiento eliminado exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;

---------------------Triggers

CREATE OR REPLACE TRIGGER TRG_BEFORE_INSERT_UPDATE_NOMBRE_TRATAMIENTO
BEFORE INSERT OR UPDATE ON Tratamientos
FOR EACH ROW
DECLARE
    p_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO p_count
    FROM Tratamientos
    WHERE UPPER(nombre) = UPPER(:NEW.nombre);

    IF p_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Ya existe un tratamiento con el mismo nombre.');
    END IF;
END;

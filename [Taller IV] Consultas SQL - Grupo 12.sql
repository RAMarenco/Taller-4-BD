--Moises Ezequiel Juárez Mejía 00038221 
--Roberto Andrés Marenco Rivas 00080121
--Rafael Andrés Quezada Azenon 00084021 

--Crear un procedimiento almacenado que se encargue de almacenar nuevas citas en la tabla CITA. El
-- procedimiento tendrá 3 parámetros de entrada: id válido de una clínica (INT). id válido de un cliente (INT).
-- fecha (VARCHAR 32) compatible con el formato DATETIME con el estilo: ‘dd/mm/yyyy hh:mm:ss:000’.
-- Distintos clientes pueden realizar varias citas en una clínica específica, ya que cada clínica dispone de los
-- servicios de varios médicos, además cada clínica cuenta con una serie de consultorios en donde podrán
-- realizarse las consultas. Por lo tanto, para poder almacenar una cita, es necesario realizar dos validaciones
-- generales:

-- 1. El procedimiento almacenado debe verificar cuántas citas se han realizado en la clínica y hora
-- especificadas en los parámetros de entrada, una vez realizada esta acción, el procedimiento debe
-- definir si la clínica aún cuenta con más consultorios disponibles para poder registrar citas en la misma
-- fecha y hora. Si la clínica no cuenta con consultorio disponible entonces el procedimiento almacenado
-- imprimirá un error explicando la situación. Por otro lado, si existen consultorios disponibles, el
-- procedimiento deberá realizar la segunda validación.

-- 2. Cada clínica cuenta con una cantidad determinada de médicos, el equipo de médicos no es
-- necesariamente igual a la cantidad de consultorios de la clínica, por lo tanto, el procedimiento
-- almacenado deberá definir si existen médicos disponibles a la hora especificada. Esta validación
-- dependerá de la cantidad de médicos de la clínica y el horario de trabajo de cada uno. Si la clínica no
-- cuenta con un médico disponible entonces el procedimiento almacenado imprimirá un error
-- explicando la situación. Por otro lado, si existen médicos disponibles, el procedimiento almacenará la
-- cita en la tabla CITA y mostrará un mensaje de que la reserva ha sido exitosa.

-- Nota: la segunda validación debe tomar en cuenta no solo la cantidad de médicos disponibles de un clínica, si
-- no también el horario de trabajo de cada médico, por ejemplo, no se pueden realizar citas a las 7:00am porque
-- ninguna clínica tiene un médico trabajando a esa hora. Cada cita debe reservarse dentro del horario de trabajo
-- de los médicos disponibles.


CREATE PROCEDURE BOOKING
        @id_Clinica INT,
        @id_Cliente INT,
        @fecha VARCHAR(32)
AS BEGIN
    BEGIN
        DECLARE @converted_date VARCHAR(32);        
        SELECT @converted_date = (CONVERT(VARCHAR(10), CONVERT(date, @fecha, 105), 23) + ' ' + CONVERT(varchar, CONVERT(time, @fecha, 105), 24));
        BEGIN
            DECLARE @cantidad_citas INT;
            SELECT @cantidad_citas = COUNT(id)
            FROM CITA WHERE id_clinica = @id_Clinica AND fecha = LEFT(@converted_date, LEN(@converted_date)-4);     

            DECLARE @consultorios INT;
            SELECT @consultorios = COUNT(*)
            FROM CONSULTORIO        
            WHERE id_clinica = @id_Clinica;  
        END
    END
    IF(@cantidad_citas >= 0 AND @consultorios > @cantidad_citas)
        BEGIN
            DECLARE @cantidad_medicos INT;
            SELECT @cantidad_medicos = count(id) 
            FROM CONTRATO 
            WHERE 
                id_clinica = @id_Clinica AND 
                CAST(@converted_date AS TIME) BETWEEN SUBSTRING(horario,1,(CHARINDEX('-',horario)-1)) AND SUBSTRING(horario,(CHARINDEX('-',horario)+1),8);            
            IF(@cantidad_medicos > @cantidad_citas)
            BEGIN
                DECLARE @ultima_cita INT;
                SELECT @ultima_cita = MAX(id) FROM CITA;
                INSERT INTO CITA VALUES((@ultima_cita+1),@id_Clinica, @id_Cliente, @converted_date);
                print 'La cita ha sido almacenada exitosamente.';
            END
            ELSE
                print 'No es posible registrar la cita porque no hay médico disponibles.';            
        END       
    ELSE
        print 'No es posible registrar la cita porque no hay consultorios disponibles.';        
END;
GO

EXEC BOOKING 1,5,'20-05-2022 09:00:00:000';
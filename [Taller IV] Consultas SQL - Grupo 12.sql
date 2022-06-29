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

            print @cantidad_citas;
            print @consultorios;
        END
    END
    IF(@cantidad_citas >= 0 AND @consultorios > @cantidad_citas)
        BEGIN
            DECLARE @cantidad_medicos INT;
            SELECT @cantidad_medicos = count(id) 
            FROM CONTRATO 
            WHERE 
                id_clinica = @id_Clinica AND 
                CAST(@converted_date AS TIME) <> (SELECT TOP(1)value FROM STRING_SPLIT(horario, '-'));            
            IF(@cantidad_medicos > @cantidad_citas)
            BEGIN
                DECLARE @ultima_cita INT;
                SELECT @ultima_cita = MAX(id) FROM CITA;
                INSERT INTO CITA VALUES((@ultima_cita+1),@id_Clinica, @id_Cliente, @converted_date);
                print 'La reserva ha sido exitosa.';
            END
            ELSE
                print 'No se pudo crear la cita, no se encuentran medicos disponibles.';            
        END       
    ELSE
        print 'No se pudo crear la cita, no se encuentran consultorios disponibles.';        
END;
GO

EXEC BOOKING 1,5,'21-05-2022 09:00:00:000';
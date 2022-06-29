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
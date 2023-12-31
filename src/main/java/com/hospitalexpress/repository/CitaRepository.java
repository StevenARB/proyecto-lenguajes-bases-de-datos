
package com.hospitalexpress.repository;

import com.hospitalexpress.model.Cita;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;

/**
 *
 * @author Cata
 */
public interface CitaRepository extends JpaRepository<Cita, Long> {

    @Procedure(name = "Cita.getCitaById")
    Map<String, Object> getCitaById(@Param("c_id_cita") Integer id_cita);

    @Procedure(name = "Cita.InsertarCita")
    void InsertarCita(
            @Param("p_id_paciente") Integer id_paciente,
            @Param("p_tipo") String tipo,
            @Param("p_fecha_hora") String fecha_hora,
            @Param("p_estado") String estado,
            @Param("p_resultado") String resultado
    );

    @Procedure(name = "Cita.getCitas")
    List<Object[]> getCitas();

    @Procedure(name = "Cita.ActualizarCita")
    String actualizarCita(
            @Param("p_id_paciente") Integer id_paciente,
            @Param("p_tipo") String tipo,
            @Param("p_fecha_hora") Date fecha_hora,
            @Param("p_estado") String estado,
            @Param("p_resultado") String resultado
    );

    @Procedure(name = "Cita.eliminarCita")
    String eliminarCita(@Param("c_id_cita") Integer id);

}

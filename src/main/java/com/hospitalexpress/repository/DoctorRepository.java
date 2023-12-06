package com.hospitalexpress.repository;

import com.hospitalexpress.model.Doctor;
import java.util.List;
import java.util.Map;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;


public interface DoctorRepository extends JpaRepository<Doctor, Long>{
       
    @Procedure(name = "Doctor.getDoctorById")
    Map<String, Object> getDoctorById(@Param("d_id_doctor") Integer id_doctor);

     @Procedure(name = "Doctor.InsertarDoctor")
        void InsertarDoctor(
        @Param("d_nombre") String nombre,
        @Param("d_direccion") String direccion,
        @Param("d_telefono") String telefono,
        @Param("d_estado") String estado,
        @Param("d_resultado") String resultado
    );
        
        @Procedure(name = "Doctor.getDoctores")
List<Object[]> getDoctores();

    @Procedure(name = "Doctor.eliminarDoctor")
    String eliminarDoctor(@Param("p_id") Integer id);
}

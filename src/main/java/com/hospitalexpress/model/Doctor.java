package com.hospitalexpress.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.NamedStoredProcedureQuery;
import jakarta.persistence.OneToOne;
import jakarta.persistence.ParameterMode;
import jakarta.persistence.StoredProcedureParameter;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "Doctor", schema = "hospitalexpress")
@Getter
@Setter
@NamedStoredProcedureQuery(name = "Doctor.getDoctorById", procedureName = "SP_CONSULTAR_DOCTOR", parameters = {
    @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_id_doctor", type = Integer.class),
    @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_nombre", type = String.class),
    @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_direccion", type = String.class),
    @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_telefono", type = String.class),
    @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_estado", type = String.class),
    @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_resultado", type = String.class)})

@NamedStoredProcedureQuery(
        name = "Doctor.insertarDoctor",
        procedureName = "SP_INSERTAR_DOCTOR",
        parameters = {
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_nombre", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_direccion", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_telefono", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_estado", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.OUT, name = "d_resultado", type = String.class)
        }
)

@NamedStoredProcedureQuery(
        name = "Doctor.getDoctores",
        procedureName = "SP_CONSULTAR_DOCTORES",
        parameters = {
            @StoredProcedureParameter(mode = ParameterMode.REF_CURSOR, name = "p_cursor", type = Object.class),
            @StoredProcedureParameter(mode = ParameterMode.OUT, name = "p_resultado", type = String.class)
        }
)

@NamedStoredProcedureQuery(
        name = "Doctor.actualizarDoctor",
        procedureName = "SP_ACTUALIZAR_DOCTOR",
        parameters = {
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_id", type = Integer.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_nombre", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_direccion", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_telefono", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "d_estado", type = String.class),
            @StoredProcedureParameter(mode = ParameterMode.OUT, name = "p_resultado", type = String.class)
        }
)

@NamedStoredProcedureQuery(
        name = "Doctor.eliminarDoctor",
        procedureName = "SP_ELIMINAR_DOCTOR",
        parameters = {
            @StoredProcedureParameter(mode = ParameterMode.IN, name = "p_id", type = Integer.class),
            @StoredProcedureParameter(mode = ParameterMode.OUT, name = "p_resultado", type = String.class)
        }
)

@NamedStoredProcedureQuery(
        name = "Doctor.getNumeroDoctores",
        procedureName = "SP_GET_NUMERO_DOCTORES",
        parameters = {
            @StoredProcedureParameter(mode = ParameterMode.INOUT, name = "p_resultado", type = Integer.class)})

public class Doctor {

    @Id
    @Column(name = "id_doctor")
    private Integer id;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "direccion")
    private String direccion;

    @Column(name = "telefono")
    private String telefono;

    @Column(name = "estado")
    private String estado;
}

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospitalexpress.repository;

import com.hospitalexpress.model.Usuario;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 *
 * @author retan
 */
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    @Procedure(name = "Usuario.insertarUsuario")
    String insertarUsuario(
            @Param("p_email") String email,
            @Param("p_password") String password,
            @Param("p_rol") String rol,
            @Param("p_estado") String estado);

    @Procedure(name = "Usuario.getUsuarioById")
    Map<String, Object> getUsuarioById(@Param("p_id_usuario") Integer id);

    @Procedure(name = "Usuario.getUsuarioByEmail")
    Map<String, Object> getUsuarioByEmail(@Param("p_email") String email);

    @Procedure(name = "Usuario.getUsuarios")
    List<Object[]> getUsuarios();

    @Procedure(name = "Usuario.actualizarUsuario")
    String actualizarUsuario(
            @Param("p_id_usuario") Integer id,
            @Param("p_email") String email,
            @Param("p_password") String password,
            @Param("p_rol") String rol,
            @Param("p_estado") String estado);

    @Procedure(name = "Usuario.eliminarUsuario")
    String eliminarUsuario(@Param("p_email") String email);

    @Procedure(name = "Usuario.getNumeroUsuarios")
    Integer getNumeroUsuarios(@Param("p_resultado") Integer resultado);

}


package com.hospitalexpress.repository;


import com.hospitalexpress.model.Producto;
import java.math.BigDecimal;
import java.util.Map;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;


public interface ProductoRepository extends JpaRepository<Producto, Long> {

    @Procedure(name = "Producto.getProductoByNombre")
    Map<String, Object> getProductoByNombre(@Param("p_nombre") String nombre);
    
    
     @Procedure(name = "Producto.insertarProducto")
    void InsertarProducto(
        @Param("p_nombre") String nombre,
        @Param("p_descripcion") String descripcion,
        @Param("p_cantidad") Integer cantidad,
        @Param("p_precio") BigDecimal precio
    );
}
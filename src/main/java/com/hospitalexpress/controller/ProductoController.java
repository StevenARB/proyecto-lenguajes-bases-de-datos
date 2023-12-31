package com.hospitalexpress.controller;

import com.hospitalexpress.model.Producto;
import com.hospitalexpress.service.ProductoService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class ProductoController {

    @Autowired
    private ProductoService productoService;

    @GetMapping("/findProductoByNombre/{nombre}")
    public String findProductoByNombre(Model model, @PathVariable String nombre) {
        try {
            Producto producto = productoService.getProductoByNombre(nombre);
            model.addAttribute("producto", producto);
        } catch (Exception e) {
            model.addAttribute("productoNoEncontrado", true);
        }
        return "producto/producto";
    }

    @GetMapping("/productos")
    public String findProductos(Model model) {
        try {
            List<Producto> listProductos = productoService.getProductos();
            if (listProductos != null) {
                model.addAttribute("productos", listProductos);
            } else {
                model.addAttribute("listaVacia", true);
            }
        } catch (Exception e) {
            model.addAttribute("listaVacia", true);
        }
        return "producto/productos";
    }

    @GetMapping("/producto/insertar")
    public String insertarProducto(Model model) {
        model.addAttribute("producto", new Producto());
        return "producto/insertar";
    }

    @PostMapping("/producto/insertar")
    public String insertarProducto(Model model, @ModelAttribute Producto producto) {
        try {
            String result = productoService.insertarProducto(
                    producto.getNombre(),
                    producto.getDescripcion(),
                    producto.getCantidad(),
                    producto.getPrecio()
            );
            model.addAttribute("resultado", result);
        } catch (Exception e) {
            model.addAttribute("error", true);
        }
        return "producto/insertar";
    }

    @GetMapping("/producto/actualizar/{id}")
    public String findProductoByIdToUpdate(Model model, @PathVariable Integer id) {
        try {
            Producto producto = productoService.getProductoById(id);
            if (producto != null) {
                model.addAttribute("producto", producto);
            } else {
                model.addAttribute("productoNoEncontrado", true);
            }
        } catch (Exception e) {
            model.addAttribute("productoNoEncontrado", true);
        }
        return "producto/actualizar";
    }

    @PostMapping("/producto/actualizar/{id}")
    public String actualizarProducto(Model model, @PathVariable Integer id, @ModelAttribute Producto producto) {
        try {
            String result = productoService.actualizarProducto(
                    id,
                    producto.getNombre(),
                    producto.getDescripcion(),
                    producto.getCantidad(),
                    producto.getPrecio()
            );
            model.addAttribute("resultado", result);
        } catch (Exception e) {
            model.addAttribute("error", true);
        }
        return "redirect:/productos";
    }

    @GetMapping("/producto/eliminar/{id}")
    public String eliminarProducto(Model model, @PathVariable Integer id) {
        try {
            String result = productoService.eliminarProducto(id);
            model.addAttribute("resultado", result);
        } catch (Exception e) {
            model.addAttribute("error", true);
        }
        return "redirect:/productos";
    }

}

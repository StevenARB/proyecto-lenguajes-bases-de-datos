package com.hospitalexpress.controller;

import com.hospitalexpress.model.Especialidad;
import com.hospitalexpress.service.EspecialidadService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class EspecialidadController {

    @Autowired
    private EspecialidadService especialidadService;

    @GetMapping("/findEspecialidadById/{id_especialidad}")
    public String findEspecialidadById(Model model, @PathVariable Integer id_especialidad) {
        try {
            if (especialidadService.getEspecialidadById(id_especialidad) != null) {
                Especialidad especialidad = especialidadService.getEspecialidadById(id_especialidad);
                System.out.println(especialidad);
                model.addAttribute("especialidad", especialidad);
            } else {
                model.addAttribute("especialidadNoEncontrada", true);
            }
        } catch (Exception e) {
            model.addAttribute("especialidadNoEncontrada", true);
        }
        return "especialidad/especialidad";
    }
    
    @GetMapping("/especialidades")
public String findEspecialidades(Model model) {
    try {
        List<Especialidad> listEspecialidades = especialidadService.getEspecialidades();
        if (listEspecialidades != null) {
            model.addAttribute("especialidades", listEspecialidades);
        } else {
            model.addAttribute("listaVacia", true);
        }
    } catch (Exception e) {
        model.addAttribute("listaVacia", true);
    }
    return "especialidad/especialidades";
}

@GetMapping("/especialidad/insertar")
public String insertarEspecialidad(Model model) {
    model.addAttribute("especialidad", new Especialidad());
    return "especialidad/insertar";
}

@PostMapping("/especialidad/insertar")
public String insertarEspecialidad(Model model, @ModelAttribute Especialidad especialidad) {
    try {
        String result = especialidadService.insertarEspecialidad(
            especialidad.getNombre(),
            especialidad.getDescripcion()
        );
        model.addAttribute("resultado", result);
    } catch (Exception e) {
        model.addAttribute("error", true);
    }
    return "especialidad/insertar";
}
    
}
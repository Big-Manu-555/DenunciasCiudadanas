package com.pacherres.denunciaservice.controller;

import com.pacherres.denunciaservice.entity.Denuncia;
import com.pacherres.denunciaservice.service.DenunciaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/denuncias")
@CrossOrigin(origins = "*")
public class DenunciaController {

    private final DenunciaService denunciaService;

    public DenunciaController(DenunciaService denunciaService) {
        this.denunciaService = denunciaService;
    }

    /**
     * 1. Registrar denuncia (POST /denuncias/ o /denuncias)
     * Registra una denuncia de inseguridad con estado inicial en 1.
     */
    @PostMapping(value = {"", "/"})
    public ResponseEntity<Denuncia> registrar(@Valid @RequestBody Denuncia denuncia) {
        Denuncia nuevaDenuncia = denunciaService.registrar(denuncia);
        return new ResponseEntity<>(nuevaDenuncia, HttpStatus.CREATED);
    }

    /**
     * 2. Obtener denuncias paginadas (GET /denuncias/?offset=0&limit=5)
     */
    @GetMapping(value = {"", "/"})
    public ResponseEntity<List<Denuncia>> listarPaginadas(
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "5") int limit) {
        List<Denuncia> lista = denunciaService.listarPaginadas(offset, limit);
        return ResponseEntity.ok(lista);
    }

    /**
     * 3. Obtener denuncia por ID (GET /denuncias/{id})
     */
    @GetMapping("/{id}")
    public ResponseEntity<Denuncia> obtenerPorId(@PathVariable Integer id) {
        Denuncia denuncia = denunciaService.obtenerPorId(id);
        return ResponseEntity.ok(denuncia);
    }

    /**
     * 4. Obtener denuncias de un ciudadano por DNI (GET /denuncias/ciudadano/{dni})
     */
    @GetMapping("/ciudadano/{dni}")
    public ResponseEntity<List<Denuncia>> obtenerPorCiudadano(@PathVariable String dni) {
        List<Denuncia> denuncias = denunciaService.obtenerPorCiudadano(dni);
        return ResponseEntity.ok(denuncias);
    }

    /**
     * 5. Atender denuncia (PUT /denuncias/{id})
     * Marca la denuncia como atendida cambiando estado de 1 a 0.
     */
    @PutMapping("/{id}")
    public ResponseEntity<Denuncia> atenderDenuncia(@PathVariable Integer id) {
        Denuncia denunciaAtendida = denunciaService.atenderDenuncia(id);
        return ResponseEntity.ok(denunciaAtendida);
    }
}


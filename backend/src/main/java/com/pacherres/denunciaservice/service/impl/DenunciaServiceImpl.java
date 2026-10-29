package com.pacherres.denunciaservice.service.impl;

import com.pacherres.denunciaservice.entity.Denuncia;
import com.pacherres.denunciaservice.exception.ResourceNotFoundException;
import com.pacherres.denunciaservice.repository.DenunciaRepository;
import com.pacherres.denunciaservice.service.DenunciaService;
import com.pacherres.denunciaservice.util.OffsetBasedPageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class DenunciaServiceImpl implements DenunciaService {

    private final DenunciaRepository denunciaRepository;

    public DenunciaServiceImpl(DenunciaRepository denunciaRepository) {
        this.denunciaRepository = denunciaRepository;
    }

    @Override
    public Denuncia registrar(Denuncia denuncia) {
        if (denuncia.getDni() == null || !denuncia.getDni().matches("^\\d{8}$")) {
            throw new IllegalArgumentException("El DNI debe tener exactamente 8 dígitos numéricos");
        }
        if (denuncia.getFecha() == null) {
            denuncia.setFecha(LocalDateTime.now());
        }
        // El estado inicial siempre debe ser 1 (pendiente/registrada)
        denuncia.setEstado(1);
        return denunciaRepository.save(denuncia);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Denuncia> listarPaginadas(int offset, int limit) {
        if (offset < 0) {
            throw new IllegalArgumentException("El parámetro offset no puede ser menor a 0");
        }
        if (limit <= 0) {
            throw new IllegalArgumentException("El parámetro limit debe ser mayor a 0");
        }
        Pageable pageable = new OffsetBasedPageRequest(offset, limit, Sort.by(Sort.Direction.ASC, "id"));
        return denunciaRepository.findAll(pageable).getContent();
    }

    @Override
    @Transactional(readOnly = true)
    public Denuncia obtenerPorId(Integer id) {
        if (id == null) {
            throw new IllegalArgumentException("El ID de la denuncia no puede ser nulo");
        }
        return denunciaRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Denuncia no encontrada con el código: " + id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<Denuncia> obtenerPorCiudadano(String dni) {
        if (dni == null || !dni.matches("^\\d{8}$")) {
            throw new IllegalArgumentException("El DNI debe tener exactamente 8 dígitos numéricos");
        }
        return denunciaRepository.findByDniOrderByIdAsc(dni);
    }

    @Override
    public Denuncia atenderDenuncia(Integer id) {
        Denuncia denuncia = obtenerPorId(id);
        // Cambia el estado de 1 a 0 (atendida)
        denuncia.setEstado(0);
        return denunciaRepository.save(denuncia);
    }
}


package com.pacherres.denunciaservice.service;

import com.pacherres.denunciaservice.entity.Denuncia;

import java.util.List;

public interface DenunciaService {

    Denuncia registrar(Denuncia denuncia);

    List<Denuncia> listarPaginadas(int offset, int limit);

    Denuncia obtenerPorId(Integer id);

    List<Denuncia> obtenerPorCiudadano(String dni);

    Denuncia atenderDenuncia(Integer id);
}


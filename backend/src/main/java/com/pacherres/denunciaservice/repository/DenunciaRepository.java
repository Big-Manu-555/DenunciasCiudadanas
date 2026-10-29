package com.pacherres.denunciaservice.repository;

import com.pacherres.denunciaservice.entity.Denuncia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DenunciaRepository extends JpaRepository<Denuncia, Integer> {

    List<Denuncia> findByDni(String dni);

    List<Denuncia> findByDniOrderByIdAsc(String dni);

    List<Denuncia> findByDniOrderByIdDesc(String dni);
}


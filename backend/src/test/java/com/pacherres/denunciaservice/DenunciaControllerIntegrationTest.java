package com.pacherres.denunciaservice;

import com.pacherres.denunciaservice.entity.Denuncia;
import com.pacherres.denunciaservice.repository.DenunciaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import java.time.LocalDateTime;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
class DenunciaControllerIntegrationTest {

    @Autowired
    private WebApplicationContext webApplicationContext;

    @Autowired
    private DenunciaRepository denunciaRepository;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        denunciaRepository.deleteAll();
    }

    @Test
    void testRegistrarDenuncia_Success() throws Exception {
        String json = """
                {
                    "dni": "76543210",
                    "fecha": "2026-10-28 10:30:00",
                    "tipo": "ROBO",
                    "direccion": "Av. Larco 1234, Miraflores",
                    "descripcion": "Robo de billetera en paradero"
                }
                """;

        mockMvc.perform(post("/denuncias/")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.dni").value("76543210"))
                .andExpect(jsonPath("$.fecha").value("2026-10-28 10:30:00"))
                .andExpect(jsonPath("$.tipo").value("ROBO"))
                .andExpect(jsonPath("$.estado").value(1));
    }

    @Test
    void testRegistrarDenuncia_FormatoFechaInvalido_400() throws Exception {
        String json = """
                {
                    "dni": "76543210",
                    "fecha": "fecha-invalida",
                    "tipo": "ROBO",
                    "direccion": "Av. Larco 1234, Miraflores",
                    "descripcion": "Robo con formato de fecha inválido"
                }
                """;

        mockMvc.perform(post("/denuncias/")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void testRegistrarDenuncia_FechaOmitida_GeneraFechaAutomatica() throws Exception {
        String json = """
                {
                    "dni": "76543210",
                    "tipo": "ROBO",
                    "direccion": "Av. Larco 1234, Miraflores",
                    "descripcion": "Robo sin enviar campo fecha"
                }
                """;

        mockMvc.perform(post("/denuncias/")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.fecha").isNotEmpty())
                .andExpect(jsonPath("$.estado").value(1));
    }

    @Test
    void testRegistrarDenuncia_DniInvalido() throws Exception {
        String json = """
                {
                    "dni": "1234",
                    "fecha": "2026-10-28 10:30:00",
                    "tipo": "ASALTO",
                    "direccion": "Calle Real 456",
                    "descripcion": "Intento de asalto"
                }
                """;

        mockMvc.perform(post("/denuncias/")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void testListarDenunciasPaginadas() throws Exception {
        for (int i = 1; i <= 7; i++) {
            Denuncia d = new Denuncia();
            d.setDni("1000000" + i);
            d.setFecha(LocalDateTime.now());
            d.setTipo("VANDALISMO");
            d.setDireccion("Parque " + i);
            d.setDescripcion("Grafitis y daños " + i);
            d.setEstado(1);
            denunciaRepository.save(d);
        }

        // Primeros 5 (offset=0, limit=5)
        mockMvc.perform(get("/denuncias/?offset=0&limit=5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(5)));

        // Siguientes 2 (offset=5, limit=5)
        mockMvc.perform(get("/denuncias/?offset=5&limit=5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)));
    }

    @Test
    void testObtenerDenunciaPorId_Existe() throws Exception {
        Denuncia d = new Denuncia();
        d.setDni("87654321");
        d.setFecha(LocalDateTime.now());
        d.setTipo("HURTO");
        d.setDireccion("Jr. Comercio 500");
        d.setDescripcion("Hurto menor");
        d.setEstado(1);
        d = denunciaRepository.save(d);

        mockMvc.perform(get("/denuncias/" + d.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(d.getId()))
                .andExpect(jsonPath("$.dni").value("87654321"));
    }

    @Test
    void testObtenerDenunciaPorId_NoExiste_404() throws Exception {
        mockMvc.perform(get("/denuncias/99999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void testObtenerDenunciasPorCiudadano() throws Exception {
        String dni = "45871234";

        Denuncia d1 = new Denuncia();
        d1.setDni(dni);
        d1.setFecha(LocalDateTime.now());
        d1.setTipo("ROBO");
        d1.setDireccion("Calle 1");
        d1.setDescripcion("Robo 1");
        denunciaRepository.save(d1);

        Denuncia d2 = new Denuncia();
        d2.setDni(dni);
        d2.setFecha(LocalDateTime.now());
        d2.setTipo("ASALTO");
        d2.setDireccion("Calle 2");
        d2.setDescripcion("Robo 2");
        denunciaRepository.save(d2);

        Denuncia d3 = new Denuncia();
        d3.setDni("99999999");
        d3.setFecha(LocalDateTime.now());
        d3.setTipo("VANDALISMO");
        d3.setDireccion("Calle 3");
        d3.setDescripcion("Robo 3");
        denunciaRepository.save(d3);

        mockMvc.perform(get("/denuncias/ciudadano/" + dni))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].dni").value(dni))
                .andExpect(jsonPath("$[1].dni").value(dni));
    }

    @Test
    void testObtenerDenunciasPorCiudadano_DniInvalido_400() throws Exception {
        mockMvc.perform(get("/denuncias/ciudadano/123"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }

    @Test
    void testAtenderDenuncia_CambiaEstadoDe1A0() throws Exception {
        Denuncia d = new Denuncia();
        d.setDni("44332211");
        d.setFecha(LocalDateTime.now());
        d.setTipo("ASALTO");
        d.setDireccion("Av. Arequipa 100");
        d.setDescripcion("Asalto a mano armada");
        d.setEstado(1);
        d = denunciaRepository.save(d);

        mockMvc.perform(put("/denuncias/" + d.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(d.getId()))
                .andExpect(jsonPath("$.estado").value(0));

        Denuncia actualizada = denunciaRepository.findById(d.getId()).orElse(null);
        org.junit.jupiter.api.Assertions.assertNotNull(actualizada);
        assertEquals(0, actualizada.getEstado());
    }

    @Test
    void testAtenderDenuncia_NoExiste_404() throws Exception {
        mockMvc.perform(put("/denuncias/99999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }
}

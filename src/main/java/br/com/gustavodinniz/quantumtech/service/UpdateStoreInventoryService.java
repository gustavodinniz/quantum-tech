package br.com.gustavodinniz.quantumtech.service;

import br.com.gustavodinniz.quantumtech.model.dto.S3EventDTO;
import br.com.gustavodinniz.quantumtech.model.dto.S3EventRecordDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UpdateStoreInventoryService {
    public void updateStoreInventory(S3EventDTO s3EventDTO) {
        log.info("Starting update store inventory...");
        Optional<S3EventRecordDTO> optionalRecord = s3EventDTO.getRecords().stream().findFirst();
        optionalRecord.ifPresentOrElse(s3Record -> {
            log.info("Bucket name: {}", s3Record.getBucketName());
            log.info("Key: {}", s3Record.getKey());
        }, () -> log.info("No records found."));
        log.info("Finished update store inventory.");
    }
}

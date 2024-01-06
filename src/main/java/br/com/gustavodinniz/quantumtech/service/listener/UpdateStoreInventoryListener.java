package br.com.gustavodinniz.quantumtech.service.listener;

import br.com.gustavodinniz.quantumtech.model.JsonParser;
import br.com.gustavodinniz.quantumtech.model.dto.S3EventDTO;
import br.com.gustavodinniz.quantumtech.service.UpdateStoreInventoryService;
import io.awspring.cloud.sqs.SqsException;
import io.awspring.cloud.sqs.annotation.SqsListener;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.sqs.model.Message;

@Slf4j
@Service
@RequiredArgsConstructor
public class UpdateStoreInventoryListener {

    private final UpdateStoreInventoryService updateStoreInventoryService;

    @SqsListener("${cloud.aws.sqs.queues.update-store-inventory}")
    public void processMessage(Message message) {
        log.info("Received a new message...");
        try {
            log.info("Trying to serialize it...");
            S3EventDTO s3EventDTO = JsonParser.stringJsonToObject(message.body(), S3EventDTO.class);
            log.info("Message serialized.");
            updateStoreInventoryService.updateStoreInventory(s3EventDTO);
        } catch (Exception e) {
            log.error("Failed to process sqs message.");
            throw new SqsException(e.getMessage(), e);
        }
    }

}

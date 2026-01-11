package com.example.devops;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "hello hello we changed the text ";
    }
    @GetMapping("/health")
    public String health() {
        return "OK";
    }

}

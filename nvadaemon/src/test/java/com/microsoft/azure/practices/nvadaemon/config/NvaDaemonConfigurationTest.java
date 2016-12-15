package com.microsoft.azure.practices.nvadaemon.config;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.platform.commons.util.Preconditions;

import java.util.ArrayList;
import java.util.List;

public class NvaDaemonConfigurationTest {
    private static String testOutputDirectory;

    @BeforeAll
    static void getProperties()
    {
        testOutputDirectory = Preconditions.notBlank(
            System.getProperty("testOutputDirectory"),
            "testOutputDirectory cannot be null or empty");
    }

    @Test
    void test_null_zookeeper_configuration() {
        Assertions.assertThrows(NullPointerException.class,
            ()-> new NvaDaemonConfiguration(null, null));
    }

    @Test
    void test_null_daemon_configuration() {
        ZookeeperConfiguration zookeeperConfiguration =
            new ZookeeperConfiguration("connection-string", "/leader-selector-path", null, null);
        Assertions.assertThrows(NullPointerException.class,
            ()-> new NvaDaemonConfiguration(zookeeperConfiguration, null));
    }

    @Test
    void test_valid_parameters() {
        ZookeeperConfiguration zookeeperConfiguration =
            new ZookeeperConfiguration("connection-string", "/leader-selector-path", null, null);
        List<MonitorConfiguration> monitors = new ArrayList<>();
        monitors.add(new MonitorConfiguration("com.company.Monitor", null));
        DaemonConfiguration daemonConfiguration = new DaemonConfiguration(monitors, null);
        NvaDaemonConfiguration nvaDaemonConfiguration = new NvaDaemonConfiguration(
            zookeeperConfiguration, daemonConfiguration);
        Assertions.assertEquals(zookeeperConfiguration,
            nvaDaemonConfiguration.getZookeeperConfiguration());
        Assertions.assertEquals(daemonConfiguration,
            nvaDaemonConfiguration.getDaemonConfiguration());
    }

    @Test
    void test_no_command_line_args() {
        Assertions.assertThrows(ConfigurationException.class,
            ()-> NvaDaemonConfiguration.parseArguments(new String[] { }));
    }

    @Test
    void test_no_config_file_specified() {
        Assertions.assertThrows(ConfigurationException.class,
            () -> NvaDaemonConfiguration.parseArguments(new String[] { "-c" }));
    }

    @Test
    void test_non_existent_config_file_specified() {
        Assertions.assertThrows(ConfigurationException.class,
            () -> NvaDaemonConfiguration.parseArguments(
                new String[] { "-c", testOutputDirectory + "/does-not-exist.json" }
            ));
    }
}

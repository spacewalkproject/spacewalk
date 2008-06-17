package com.redhat.satellite.search.tests;

import com.redhat.satellite.search.config.Configuration;

import org.picocontainer.defaults.DefaultPicoContainer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class TestUtil {

    private TestUtil() {

    }
    
    @SuppressWarnings("unchecked")
    public static DefaultPicoContainer buildContainer(Class[] components) throws IOException {
        Configuration config = makeConfiguration();
        DefaultPicoContainer container = new DefaultPicoContainer();
        container.registerComponentInstance("appConfig", config);
        for (int x = 0; x < components.length; x++) {
            container.registerComponentImplementation(components[x]);
        }
        return container;
    }
    
    @SuppressWarnings("unchecked")
    public static Class[] buildComponentsList(Class component) {
        Class[] arg = {component};
        return buildComponentsList(arg);
    }
    
    @SuppressWarnings("unchecked")
    public static Class[] buildComponentsList(Class[] components) {
        List<Class>accum = new ArrayList<Class>();
        for (int x = 0; x < components.length; x++) {
            processComponent(components[x], accum);
        }
        Class[] retval = new Class[accum.size()];
        accum.toArray(retval);        
        return retval;        
    }

    public static Configuration makeConfiguration() throws IOException {
        String prefix = "search-server-test";
        String indexWorkDir = generateTempDir(prefix);
        StringBuilder builder = new StringBuilder();
        builder.append("search.index_work_dir=").append(indexWorkDir).append("\n");
        builder.append("search.rpc_port=").append(generatePortNumber()).append("\n");
        builder.append("search.rpc_handlers=");
        builder.append("index:com.redhat.satellite.search.rpc.handlers.IndexHandler\n\n");
        
        // see if we overrode any properties in test.properties
        File f = new File("src/config/test.properties");
        if (f.exists()) {
            FileReader fr = new FileReader(f);
            BufferedReader br = new BufferedReader(fr);
            String line = null;
            while ((line = br.readLine()) != null) {
                builder.append(line);
                builder.append("\n");
            }
        }

        StringReader sr = new StringReader(builder.toString());
        return new Configuration(new BufferedReader(sr));
    }

    public static void cleanupDirectories(Configuration config)
            throws IOException {
        String workDir = config.getString("search.index_work_dir", null);
        if (workDir != null) {
            File f = new File(workDir);
            if (f.exists() && f.isDirectory()) {
                Runtime.getRuntime().exec("rm -rf " + workDir);
            }
        }
    }
    @SuppressWarnings("unchecked")
    private static List<Class> processComponent(Class component, List<Class>accum) {
        if (component == Configuration.class) {
            return accum;
        }
        if (accum.indexOf(component) == -1) {
            accum.add(component);
        }
        Constructor[] constructors = component.getConstructors();
        if (constructors != null) {
            for (int x = 0;x < constructors.length; x++) {
                Class[] paramTypes = constructors[x].getParameterTypes();
                if (paramTypes.length > 0) {
                    for (int y = 0;y < paramTypes.length; y++) {
                        if (isCandidate(paramTypes[y].getName())) {
                            processComponent(paramTypes[y], accum);
                        }
                    }
                }
            }
        }
        return accum;
    }
    
    private static boolean isCandidate(String className) {
        boolean retval = true;
        if (className.startsWith("java.") || className.startsWith("javax.") || 
                className.startsWith("com.sun.")) {
            retval = false;
        }
        return retval;
    }

    private static String generateTempDir(String prefix) throws IOException {
        File f = File.createTempFile(prefix, null);
        f.delete();
        return f.getAbsolutePath();
    }

    private static String generatePortNumber() {
        Random r = new Random(System.nanoTime());
        int port = 0;
        while (port < 1024) {
            port = r.nextInt(20001);
        }
        return String.valueOf(port);
    }
}

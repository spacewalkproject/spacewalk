/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.internal.doclet;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 *
 * DocWriter
 * @version $Rev$
 */
public abstract class DocWriter {


    protected VelocityHelper serializerRenderer;


    /**
     * Constructor
     *
     */
    public DocWriter() {

    }

    protected  void writeFile(String filePath, String contents) throws Exception {
       FileWriter fileWrite = new FileWriter(filePath);
       BufferedWriter bw = new BufferedWriter(fileWrite);
       bw.write(contents);
       bw.close();

   }

    protected String readFile(String filePath) throws Exception {
        String toReturn = "";
        FileReader input = new FileReader(filePath);
        BufferedReader bufRead = new BufferedReader(input);
        String line = bufRead.readLine();

        while (line != null) {
            toReturn += line + "\n";
            line = bufRead.readLine();
        }
        bufRead.close();
        return toReturn;
   }

    /**
     * Generate the index from the template dir from (API_HEADER/INDEX/FOOTER_FILE) files
     * @param handlers list of the handlers
     * @param templateDir directory of the templates
     * @return a string representing the index
     * @throws Exception e
     */
    public  String generateIndex(List<Handler> handlers, String templateDir)
                throws Exception {


        VelocityHelper vh = new VelocityHelper(templateDir);
        vh.addMatch("handlers", handlers);
        String output = vh.renderTemplateFile(ApiDoclet.API_HEADER_FILE);
        output += vh.renderTemplateFile(ApiDoclet.API_INDEX_FILE);
        output += vh.renderTemplateFile(ApiDoclet.API_FOOTER_FILE);
        return output;
    }

    /**
     * generate a templated handler from teh template dir and the file (API_HANDLER_FILE)
     * @param handler the handler in question
     * @param templateDir the directory of templates
     * @return a string that is the templated handler
     * @throws Exception e
     */
    public String generateHandler(Handler handler, String templateDir)
            throws Exception {

        for (ApiCall call : handler.getCalls()) {
            call.setReturnDoc(renderMacro(templateDir, call.getReturnDoc(),
                    call.getName()));
            List<String> params = new ArrayList<String>();

            for (String param : call.getParams()) {
                params.add(renderMacro(templateDir, param,
                        "param:" + param));
            }
            call.setParams(params);

        }

        VelocityHelper vh = new VelocityHelper(templateDir);
        vh.addMatch("handler", handler);
        String output = vh.renderTemplateFile(ApiDoclet.API_HANDLER_FILE);

        //Now we render the serializers
        output = serializerRenderer.renderTemplate(output);


        return output;
    }

    /**
     * Renders the input agains the api macros file in a given directory.
     * @param templateDir The directory of the macros.txt file
     * @param input the input to macrotize
     * @param description a description to use in case something goes wrong
     * @return the macrotized input
     * @throws Exception e
     */
    public String renderMacro(String templateDir, String input, String description)
                    throws Exception {
        VelocityHelper macros = new VelocityHelper();
        String macro = readFile(templateDir + ApiDoclet.API_MACROS_FILE);

        try {
            String toReturn = macros.renderTemplate(macro + input + " \n ");
            return toReturn;
        }
        catch (Exception e) {
            String errrorFile = "/tmp/apidoc_error.txt";
            System.out.println("ATTN!!!!!!!!!!");
            System.out.println("There was an error macro-tizing " + description);
            System.out.println("We have dumped the full text to "  + errrorFile + ".");
            System.out.println("Please lookup the appropriate line number printed " +
                    "in the following traceback and reference it with the written file.");
            writeFile(errrorFile,  macro + input + "\n");
            throw e;
        }

    }

    /**
     * render the serializers
     * @param templateDir the template directory for this writer
     * @param serializers Map of serializers
     * @throws Exception e
     */
    public void renderSerializers(String templateDir, Map<String, String> serializers)
                    throws Exception {

        serializerRenderer = new VelocityHelper();

        //macrotize the serializers
        for (String name : serializers.keySet()) {
            String temp = renderMacro(templateDir, serializers.get(name), name);
            serializers.put(name, temp);
            serializerRenderer.addMatch(name, serializers.get(name));
        }

        //do replacement on the serializers serveral times
        for (int i = 0; i < 3; i++) {
            VelocityHelper tempRenderer = new VelocityHelper();
            for (String name : serializers.keySet()) {
                String temp = serializerRenderer.renderTemplate(serializers.get(name));
                serializers.put(name, temp);
                tempRenderer.addMatch(name, temp);
            }
            serializerRenderer = tempRenderer;
        }
    }


    /**
     * write the specified writer
     * @param handlers list of handlers
     * @param serializers a list of serializers to write with
     * @throws Exception e
     */
    public abstract void write(List<Handler> handlers,
            Map<String, String> serializers) throws Exception;


}

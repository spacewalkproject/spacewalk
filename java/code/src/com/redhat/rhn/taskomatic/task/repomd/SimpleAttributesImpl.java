package com.redhat.rhn.taskomatic.task.repomd;

import org.xml.sax.helpers.AttributesImpl;

public class SimpleAttributesImpl extends AttributesImpl {
	/**
	 * 
	 * @param name attribute anme
	 * @param value attribute value
	 */
    public void addAttribute(String name, String value) {
        addAttribute("", "", name, null, value);
    }
}

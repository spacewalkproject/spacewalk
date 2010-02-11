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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.html.HtmlTag;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;

/**
 * SetTag
 * @version $Rev$
 */
public class SetTag extends ColumnTag {
    private String radioElement;
    private Long element;
    private Long elementTwo;
    private String img;
    private String title;
    private String alt;
    private String type;
    private boolean showButtons = true;
    private boolean showImg = false;
    private boolean disabled = false;

    /**
     * Constructor
     */
    public SetTag() {
        super();
    }
    
    /**
     * {@inheritDoc}
     */
    public int doStartTag() throws JspException {
        if (showButtons) {
            findListDisplay().showButtons();
        }
        return super.doStartTag();
    }
    
    /**
     * Turns the button bar on or of
     * @param flag indicates whether or not to render the button bar, defaults to on
     */
    public void setButtons(String flag) {
       if (flag != null) {
           if (flag.equalsIgnoreCase("no") || flag.equalsIgnoreCase("false") || 
                   flag.equalsIgnoreCase("n") || flag.equalsIgnoreCase("off")) {
               showButtons = false;
           }
       }
    }

    /**
     * Copy Constructor
     * @param s SetTag to copy
     */
    public SetTag(SetTag s) {
        super(s);
        setRadioElement(s.radioElement);
        setElement(s.getElement());
        setElementTwo(s.getElementTwo());
        img = s.getImg();
        title = s.getTitle();
        alt = s.getAlt();
    }
    
    /**
     * {@inheritDoc}
     */
    protected String renderHeaderData(String hdr, String arg) {
        //We don't care what hdr is, we're rendering a checkbox!
        HtmlTag cbox = new HtmlTag("input");
        if (type == null || type.equals("checkbox")) {
            if (getSet() == null) {
                throw new IllegalArgumentException("Your RhnSet is null.  Most " +
                        "likely your class didn't call BaseSetListAction.proces" +
                        "sRequestAttributes to set the 'set' on the request"); 
            }
            cbox.setAttribute("type", "checkbox");
            cbox.setAttribute("name", "checkall");
            cbox.setAttribute("id", "rhn_javascriptenabled_checkall_checkbox");
            cbox.setAttribute("onclick", "check_all_on_page(this.form, '" +
                    getSet().getLabel() + "')");
            cbox.setAttribute("title", LocalizationService.getInstance()
                    .getMessage("settag.select"));
            cbox.setAttribute("alt", LocalizationService.getInstance()
                    .getMessage("settag.select"));
            cbox.setAttribute("style", "display: none");
            cbox.setAttribute("@@CHECKED@@", "");
            return cbox.render();
        }
        else if (isRadio()) {
            return "";
        }
        return null;
    }
    
    /**
     * {@inheritDoc}
     */
    protected void renderData(JspWriter out, ListDisplayTag parent)
        throws IOException {
        super.renderData(out, parent);
        //Render contents of column here
        if (isShowImg()) {
            HtmlTag image = new HtmlTag("img");
            image.setAttribute("src", getImg());

            if (this.getTitle() != null) {
                image.setAttribute("title", LocalizationService.getInstance()
                                   .getMessage(this.getTitle()));
            }

            if (this.getAlt() != null) {
                image.setAttribute("alt", LocalizationService.getInstance()
                                   .getMessage(this.getAlt()));
            }

            out.print(image.render());
        }
        else {
            HtmlTag cbox = new HtmlTag("input");
            if (type == null || type.equals("checkbox")) {
                cbox.setAttribute("type", "checkbox");
                cbox.setAttribute("onclick", "checkbox_clicked(this, '" +
                                  getSet().getLabel() + "')");
            }
            else {
                cbox.setAttribute("type", "radio");
            }
            cbox.setAttribute("name", "items_selected");            
            cbox.setAttribute("value", getValue());

            //Should checkbox be checked?
            if (checkboxChecked()) {
                cbox.setAttribute("checked", "true");
                parent.incrementChecked();
            }

            //Should checkbox be disabled?
            if (disabled) {
                cbox.setAttribute("disabled", "disabled");
            }

            if (this.getTitle() != null) {
                cbox.setAttribute("title", LocalizationService.getInstance()
                                  .getMessage(this.getTitle()));
            }

            if (this.getAlt() != null) {
                cbox.setAttribute("alt", LocalizationService.getInstance()
                                  .getMessage(this.getAlt()));
            }
        
            HtmlTag hideme = new HtmlTag("input");
            hideme.setAttribute("type", "hidden");
            hideme.setAttribute("name", "items_on_page");
            hideme.setAttribute("value", getValue());
        
            out.print(cbox.render() + "\n" + hideme.render());
        }
    }

    /**
     * Decides if checkbox should be checked or left alone
     * @param cbox checkbox to check (maybe)
     * @return whether the checkbox should be checked
     */
    private boolean checkboxChecked() {
        RhnSet set = getSet();
        if (set != null && set.contains(element, elementTwo)) {
            return true;
        }
    
        return false;
    }

    /**
     * @return Returns the value.
     */
    public String getValue() {
        if (isRadio()) {
            return radioElement;
        }
        if (elementTwo == null) {
            return element.toString();
        }
        return element.toString() + "|" + elementTwo.toString();
    }
    
    /**
     * @param v The value to set.
     */
    public void setValue(String v) {
        setElement(v);
    }
    
    private void setRadioElement(String elem) {
        radioElement = elem;
    }
    
    /**
     * @return Returns the element.
     */
    public String getElement() {
        if (element == null) {
            return null;
        }
        return element.toString();
    }
    
    private boolean isRadio() {
        return "radio".equals(getType());
    }
    
    /**
     * @param elementIn The element to set.
     */
    public void setElement(String elementIn) {
        if (elementIn != null && elementIn.length() > 0) {
            if (isRadio()) {
                radioElement = elementIn;
            }
            else {
                element = new Long(elementIn);                
            }
        }
    }
    /**
     * @return Returns the elementTwo.
     */
    public String getElementTwo() {
        if (elementTwo == null) {
            return null;
        }
        return elementTwo.toString();
    }
    /**
     * @param elementIn The elementTwo to set.
     */
    public void setElementTwo(String elementIn) {
        if (elementIn != null && elementIn.length() > 0) {
            elementTwo = Long.decode(elementIn);
        }
    }
    /**
     * @return Returns the set.
     */
    public RhnSet getSet() {
        return findListDisplay().getSet();
    }
    /**
     * @return Returns the img.
     */
    public String getImg() {
        return img;
    }
    /**
     * @param imgIn The img to set.
     */
    public void setImg(String imgIn) {
        this.img = imgIn;
    }
    /**
     * @return Returns the showImg.
     */
    public boolean isShowImg() {
        return showImg;
    }
    /**
     * @param showImgIn The showImg to set.
     */
    public void setShowImg(boolean showImgIn) {
       this.showImg = showImgIn;     
    }
    /**
     * @return Returns the title.
     */
    public String getTitle() {
        return title;
    }
    /**
     * @param titleIn The title to set.
     */
    public void setTitle(String titleIn) {
        this.title = titleIn;
    }
    /**
     * @return Returns the alt.
     */
    public String getAlt() {
        return alt;
    }
    /**
     * @param altIn The alt to set.
     */
    public void setAlt(String altIn) {
        this.alt = altIn;
    }
    /**
     * @return Returns the disabled.
     */
    public boolean isDisabled() {
        return disabled;
    }
    /**
     * @param disabledIn The disabled to set.
     */
    public void setDisabled(boolean disabledIn) {
        this.disabled = disabledIn;
    }

    
    /**
     * Get the type of selectors for the set:  "radio" or "checkbox"
     * @return the type
     */
    public String getType() {
        return type;
    }

    
    /**
     * Set the type of selectors for the set:  "radio" or "checkbox".  
     * @param typeIn The type to set.
     */
    public void setType(String typeIn) {
        if (!typeIn.equals("radio") && !typeIn.equals("checkbox")) {
            throw new IllegalArgumentException("Unknown type: " + typeIn);
        }
        this.type = typeIn;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        element = null;
        elementTwo = null;
        radioElement = null;
        img = null;
        title = null;
        alt = null;
        type = null;
        showImg = false;
        disabled = false;
        super.release();
    }
}

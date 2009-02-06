package com.redhat.rhn.domain.errata;

public class Cve {
	
	private Long id;
	private String name;
    
	/**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
	public void setName(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}
	
	

}

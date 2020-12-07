/**
 * File Name: fflib_EventListenerSelector 
 * Description: 
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public interface fflib_EventListenerSelector
{
	List<fflib_EventListenerConfig> getEventListeners(String namespace, String eventName);
}
# Events

### Emitter and listeners

With the event emitter and listener interfaces events can be thrown and captured in Apex.
The events feature can be used to handle custom events and SObject trigger events.
```
                                                        + - - - - - - - - +
+ - - - - - - - +          + - - - - - - - +         + - - - - - - - - + |
| Event occurs  | - - - >  | Event Emitter | - - - > | Event Listeners | +
+ - - - - - - - +          + - - - - - - - +         + - - - - - - - - + 
```
An event has a name and can have a payload with data.
Listeners can be added or removed in run-time. 
They can be configured to be executed;
 - in a certain order of priority,
 - as Queueable Apex.

### Application event Emitter

The purpose of the emitter is to publish an event by calling all the listeners for that event.

The Application class contains an application wide emitter, 
which will automatically load the configured listeners 
and will call the corresponding implementation of that event listener.

```
| Apex class    |  App Event Emitter      | Event Listener Selector   | Binding Resolver              |
+ - - - - - - - + - - - - - - - - - - - - + - - - - - - - - - - - - - + - - - - - - - - - - - - - - - +
|               |                         |                           |                               |
| Event occurs -|-> emit('MyEvent')      -|-> selectByName('MyEvent') |                               | 
|               |                         |              |            |                               |       
|               |   eventListeners   < - -| - - List - - +            |                               |
|               |     ^       |           |                           |                               |   
|               |     |    iterate        |                           |                               |     
|               |     |       |           |                           |                               |
|               |     |       |  - - - - - - - - - - - - - - - - - - -|-> newInstance(eventListener)  |   
|               |     |       |           |                           |        |                      |
|               |     |       |  < - - - - - - - - - - - - - - - - - -|- - - - +                      |   
|               |     |       |           |                           |                               |
|               |     |  listener.handle()|                           |                               |
|               |     |       |           |                           |                               |
|               |     + - - - +           |                           |                               |
|               |                         |                           |                               |
+ - - - - - - - + - - - - - - - - - - - - + - - - - - - - - - - - - - + - - - - - - - - - - - - - - - +
```
The selector is in control of which type event the application can listen for and where the configuration is stored.
Be careful with including all listeners as multiple managed packages might emit the same event,
by default you only want to listen to your own (namespace) events.

The Application Event Emitter is using lazy loading of the listeners to avoid memory overload.

### Trigger handling

This event feature is an ideal replacement for the old style trigger handler (fflib_SObjectDomain).

```
| Apex Trigger    |  fflib_SObjectEvent     | Application Event         |  fflib_SObjectEventListener   | 
+ - - - - - - - - + - - - - - - - - - - - - + - - - - - - - - - - - - - + - - - - - - - - - - - - - - - +
|                 |                         |                           |                               |
| execution  - - -|-> new instance          |                           |                               |
|                 |        |                |                           |                               |
| sObjectEvent  <-|- - - - +                |                           |                               |
|                 |                         |                           |                               |
|  - - - - - - - - - - - - - - - - - - - - -|-> emit(sObjectEvent)      |                               |        
|                 |                         |          |                |                               |
|                 | getName   <- - - - - - -|- - - - - +                |                               |
|                 |    |                    |                           |                               |
|                 |    + - - - - - - - - - -|-> eventName               |                               |
|                 |                         |                           |                               |
|                 |                         |   [select Listeners]      |                               |
|                 |                         |                           |                               |
|                 |                         |   call each listener - - -|-> handle()                    |
|                 | getData <- - - - - - - -|- - - - - - - - - - - - - - - - -                          |
|                 |    |                    |                           |                               |
|                 |    + - - - - - - - - - - - - (Trigger.new) - - - - -|-> eventData                   |
|                 |                         |                           |                               |
|                 | getOperationType  <- - -|- - - - - - - - - - - - - -|- - -                          |
|                 |    |                    |                           |                               |
|                 |    + - - - - - - - - (System.TriggerOperation) - - -|-> operationType               |
|                 |                         |                           |                               |
|                 |                         |                           |   depending on operationType: |
|                 |                         |                           |    - onBeforeInsert()         |
|                 |                         |                           |    - onAfterInsert()          |
|                 |                         |                           |    - onBeforeUpdate()         |
|                 |                         |                           |    - onAfterUpdate()          |
|                 |                         |                           |    - onBeforeDelete()         |
|                 |                         |                           |    - onAfterDelete()          |
|                 |                         |                           |    - onAfterUndelete()        |
|                 |                         |                           |                               |
+ - - - - - - - - + - - - - - - - - - - - - + - - - - - - - - - - - - - + - - - - - - - - - - - - - - - +
```
The event is emitter from the Apex Trigger. 
It utilises the fflib_SObjectEvent to generate a name for the event, based on the SObjectType and the TriggerOperation.



## Examples

## Execution in realtime

Let's create a very basic example of an event listener and emit an event.
The example below will output the eventData to the debug-log.
```apex
public with sharing class MyEventListener implements fflib_EventListener
{
    public void handle(fflib_Event event)
    {
        String eventData = (String) event.getContext().getEventData();
        System.debug(eventData);
    }
}
``` 
 
To publish an event and call the listener, the listener must first be registered in the event emitter. 
Then the event is published, and the listener will be invoked.

```apex
public with sharing class MyController
{
    private fflib_EventEmitter eventEmitter;

    public MyController()
    {
        eventEmitter = new fflib_EventEmitterImp();
        eventEmitter.addListener('MyEvent', MyEventListener.class);    
    }

    public void callEvent()
    {
        eventEmitter.emit('MyEvent', 'Hello World');
    }
}
```

This should output 'Hello World' in the debug-log.


## Execution in near-time (via Queueable)

Running many event listeners in realtime can cause issues with limits. 
Therefore, it can be useful to have listeners running in their own execution context.
 
The same listener can be used as shown in the previous example.
```apex
public with sharing class MyEventListener implements fflib_QueueableEventListener
{
    public void handle(fflib_Event event)
    {
        String eventData = String.valueOf(event.getData());
        System.debug(eventData);
    }
}
``` 

Then in the controller the event listener is registered as queueable and the event is emitted.

```apex
public with sharing class MyController
{
    private fflib_EventEmitter eventEmitter;

    public MyController()
    {
        eventEmitter = new fflib_EventEmitterImp();
        eventEmitter.addQueueableListener('MyEvent', MyEventListener.class);    
    }

    public void callEvent()
    {
        eventEmitter.emit('MyEvent', 'Hello World');
    }
}
```
After execution there should be a second debug-log containing the message 'Hello World'.


## Call listeners in a particular order

In some case there is a need to call listeners in a particular order.

-- Todo --

## Trigger handling with events. 

In the **Application class** we define the Application Event Emitter, 
link the selector to the event listeners 
and define the bindings of the event listener interface to its implementation. 
```apex
public class Application
{
    // This will bind the defined event listener interfaces to it implementation
    public static final fflib_BindingResolver EventListenerBindings =
            new fflib_ClassicBindingResolver(
                    new Map<Type, Type>
                    {
                            OnChangedAccountSanitizer.class => OnChangedAccountSanitizerImp.class
                    }    
            );

    public static final fflib_ApplicationEventEmitter eventEmitter =
            new fflib_ApplicationEventEmitterImp(
            
                    // The Namespace of the application to emit the event.
                    'MyNameSpace',

                    // The selector that queries the event listeners (List<fflib_EventListenerConfig>), 
                    // The default is shown here but can be replaced with another selector
                    // to retrieve the listeners from wherever they are stored        
                    fflib_MetadataEventListenerSelector.class,  

                    // The reference to the bindings to link interface and implementation 
                    fflib_Application.EventListenerBindings     
            );
}
```

On the fflib_EventListener__mdt custom metadata object we need to define the listener and to which event it listens.

**fflib_EventListeners.OnChangeAccountSanitize.md-meta.xml**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>OnChangeAccount Sanitize</label>
    <protected>false</protected>
    <values><field>EventName__c</field>    <value xsi:type="xsd:string">Account.BEFORE_UPDATE</value>    </values>
    <values><field>InterfaceType__c</field><value xsi:type="xsd:string">OnChangedAccountSanitizer</value></values>
    <values><field>Priority__c</field>     <value xsi:type="xsd:double">0.0</value>                      </values>
    <values><field>QueuedAction__c</field> <value xsi:type="xsd:boolean">false</value>                   </values>
</CustomMetadata>
```

An event is published in the trigger. 
The event name is a combination of the SObjectType and the operationType, e.g. 'Account.AFTER_INSERT'.
```apex
trigger AccountEvent on Account
        (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
    Application.eventEmitter.emit(new ffib_SObjectEvent());
}
```


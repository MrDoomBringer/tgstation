import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Flex, ByondUi, Divider, Section, Tabs,Knob, Box, Button, Fragment, ProgressBar, NumberInput, Icon, Input, LabeledList } from '../components';
import { Window } from '../layouts';

const skillgreen = {
  color: '#FFE8F0'
};
const dropoff_yellow = {
  color: '#FFDB58'
};

const dropoff_grey = {
  color: 'grey'
};

export const CentcomPodLauncher = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
    resizable
    title=" Config/Launch Supply Pod"

    width={690}
    height={420}>
      <CentcomPodLauncherContent />
    </Window>
  );
};

const CentcomPodLauncherContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  const OptionsPage = PAGES[pageIndex].component();
  const marginer = 0.5
  return (
    <Window.Content>
			<Flex height="100%">
				<Flex.Item width="30%">
					<Flex direction="column" height="100%" >
						<Flex.Item  grow={1} m={marginer} >
            <PresetsPage />
						</Flex.Item>
						<Flex.Item grow={0}  m={marginer}>
							<ReverseMenu />
						</Flex.Item>
						<Flex.Item height="80px" m={marginer}>
              <LaunchPage />
						</Flex.Item>
					</Flex>
    		</Flex.Item>


        <Flex.Item width="40%"  >
					<Flex direction="column" height="100%">
            <Flex.Item grow={1} m={marginer}>
              <ViewTabHolder />
            </Flex.Item>

						<Flex.Item maxHeight="150px" m={marginer}>
              <StylePage />
                    
						</Flex.Item>

          </Flex>
        </Flex.Item>
        
				<Flex.Item width="30%" >    
					<Flex direction="column" height="100%">
						<Flex.Item grow={1} m={marginer} >
            <OptionsMenu />
            
						</Flex.Item>
						<Flex.Item maxHeight="250px" m={marginer} >
            
            <OptionsPage />
						</Flex.Item>
					</Flex>
				</Flex.Item>
      </Flex>

    </Window.Content>
  );
};


const PAGES = [
  {
    title: 'Loading the Pod',
    component: () => LoadingMethod,
  },
  {
    title: 'Effects',
    component: () => NormalEffects,
  },
  {
    title: 'Harmful Effects',
    component: () => HarmfulEffects,
  },
  {
    title: 'Custom Timings',
    component: () => Timing
  },
  {
    title: 'Custom Sounds',
    component: () => LoadingMethod,
  }
];

const TABPAGES = [
  {
    title: 'View Pod',
    component: () => TabPod,
  },
  {
    title: 'View Bay',
    component: () => TabBay,
  }
];

const REVERSE_OPTIONS = [
  {
    title: 'Mobs'
  },
  {
    title: 'Objects'
  },
  {
    title: 'Anchored'
  },
  {
    title: 'Floors'
  },
  {
    title: 'Walls'
  }
];


const DELAYS = [
  {
    title: 'Master',
    component: () => LoadingMethod,
  },
  {
    title: 'Launch Delay',
    component: () => LoadingMethod,
  },
  {
    title: 'Fall  Duration',
    component: () => HarmfulEffects,
  },
  {
    title: 'Open Delay',
    component: () => NormalEffects,
  },
  {
    title: 'Leave Delay',
    component: () => LoadingMethod,
  }
];
const STYLES = [
  {
    title: 'Standard',
  },
  {
    title: 'Advanced',
  },
  {
    title: 'Nanotrasen',
  },
  {
    title: 'Syndicate',
  },
  {
    title: 'Deathsquad',
  },
  {
    title: 'Cultist',
  },
  {
    title: 'Missile',
  },
  {
    title: 'Red Missile',
  },
  {
    title: 'Supply Box',
  },
  {
    title: 'Clown Pod',
  },
  {
    title: 'Fruit',
  },
  {
    title: 'Invisible',
  },
  {
    title: 'Gondola',
  },
  {
    title: 'Seethrough',
  }

  
];
const PRESETS = [
  {
    title: 'Preset 1'
  },
  {
    title: 'Preset 2'
  },
  {
    title: 'Preset 3'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  },
  {
    title: 'Preset 4'
  }
];
const OptionsMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  return (
    <Section title="Options" fill>
								<Tabs vertical>
									{PAGES.map((page, i) => (
										<Tabs.Tab
											key={i}
											selected={i === pageIndex}
											onClick={() => setPageIndex(i)}>
											{page.title}
										</Tabs.Tab>
									))}
								</Tabs>
							</Section>
  );
                  };

const ViewTabHolder = (props, context) => {
  const { act, data, config } = useBackend(context);
  const [tabPageIndex, setTabPageIndex] = useLocalState(context, 'tabPageIndex', 1);
  const { mapRef } = data;

  const TabPageComponent = TABPAGES[tabPageIndex].component();
  return (
    <Section title="View" fill buttons={(
            <Fragment>
                  {(data.dropoff_turf && data.effectReverse===1) && (
                    <Button
                      inline
                      color="transparent"
                      tooltip="View Dropoff Location"
                      tooltipPosition="left"
                      icon="arrow-circle-down"
                      selected={2 === tabPageIndex}
                      onClick={() => {
                        setTabPageIndex(2);
                        act('tabSwitch', {tabIndex: 2});
                        }}/>
                    )}
                  <Button
                    inline
                    color="transparent"
                    tooltip="View Pod"
                    tooltipPosition="left"
                    icon="rocket"
                    selected={0 === tabPageIndex}
                    onClick={() => {
                      setTabPageIndex(0);
                      act('tabSwitch', {tabIndex: 0});
                      }}/>
                    
                  <Button
                    inline
                    color="transparent"
                    tooltip="View Source Bay"
                    tooltipPosition="left"
                    icon="th"
                    selected={1 === tabPageIndex}
                    onClick={() => {
                      setTabPageIndex(1);
                      act('tabSwitch', {tabIndex: 1});
                      }}/>
                    <span style={dropoff_grey}>|</span>
                  <Button
                    inline
                    tooltipPosition="left"
                    color="transparent"
                    icon="sync-alt"
                    tooltip="Refresh view window in case it breaks"
                    onClick={() => {
                      setTabPageIndex(1);
                      act('tabSwitch', {tabIndex: 1});
                      }}/>
                </Fragment>
                )}>
                <Flex direction="column" height="100%"> 
                  <Flex.Item m={0.5}>
                    <TabPageComponent />
                  </Flex.Item>
                  <Flex.Item m={0.5} grow={1}>
                    <Section fill>
                    <ByondUi
                    fillPositionedParent
                    params={{
                      zoom: 0,
                      id: mapRef,
                      parent: config.window.id,
                      type: 'map',
                    }} />
                    </Section>
                  
                  </Flex.Item>
                </Flex>
             
              </Section>
  );
};

const TabBay = (props, context) => {
  const { act, data, config } = useBackend(context);
  
  return (

      <Fragment>
      <Button
        content="Teleport"
        icon="street-view"
        onClick={() => act('teleportCentcom')} />
      <Button
        content={data.oldArea ? data.oldArea : 'Go Back'}
        disabled={!data.oldArea}
        icon="undo-alt"
        onClick={() => act('teleportBack')} />
     </Fragment>

  );
};

const TabPod = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef } = data;
  return (
    
    <Fragment>
      <Button
        content="Custom Name/Desc"
        selected={data.effectName}
        tooltip="Allows you to add a custom name and description."
        onClick={() => act('effectName')} />
   </Fragment>


  );
};


const LoadingMethod = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>

      
      <Section
              fill
        overflow-y="scroll">
        <OptionLabel 
        title="Turf Selection Method">
            <Button
              content="Bay #1"
              selected={data.bayNumber === 1}
              onClick={() => act('bay1')} />
            <Button
              content="Bay #2"
              selected={data.bayNumber === 2}
              onClick={() => act('bay2')} />
            <Button
              content="Bay #3"
              selected={data.bayNumber === 3}
              onClick={() => act('bay3')} />
            <Button
              content="Bay #4"
              selected={data.bayNumber === 4}
              onClick={() => act('bay4')} />
            <Button
              content="ERT Bay"
              selected={data.bayNumber === 5}
              tooltip={multiline`
                This bay is located on the western edge of CentCom. Its the
                glass room directly west of where ERT spawn, and south of the
                CentCom ferry. Useful for launching ERT/Deathsquads/etc. onto
                the station via drop pods.
              `}
              onClick={() => act('bay5')} />
          </OptionLabel>
        <OptionLabel title="Turf Selection Method">
            <Button
          content="Ordered"
          selected={data.launchChoice === 1}
          tooltip={multiline`
            Instead of launching everything in the bay at once, this
            will "scan" things (one turf-full at a time) in order, left
            to right and top to bottom. undoing will reset the "scanner"
            to the top-leftmost position.
          `}
          onClick={() => act('launchOrdered')} />
        <Button
          content="Random Turf"
          selected={data.launchChoice === 2}
          tooltip={multiline`
            Instead of launching everything in the bay at once, this
            will launch one random turf of items at a time.
          `}
          onClick={() => act('launchRandomTurf')} />
           
            </OptionLabel>
        

        <OptionLabel title="Item Loading Method">
         
          <Button
          content="Clone"
          selected={data.launchClone}
          tooltip={multiline`
            Choosing this will create a duplicate of the item to be
            launched in Centcom, allowing you to send one type of item
            multiple times. Either way, the atoms are forceMoved into
            the supplypod after it lands (but before it opens).
          `}
          onClick={() => act('launchClone')} />
        <Button
          content="Random"
          selected={data.launchRandomItem}
          tooltip={multiline`
            Choosing this will pick a random item from the selected turf
            instead of the entire turfs contents. Best combined with
            single/random turf.
          `}
          onClick={() => act('launchRandomItem')} />
         
        </OptionLabel>
        
      </Section>
    </Fragment>
  );
};

const HarmfulEffects = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      <Section fill>
        <OptionLabel title="Explosion on Landing" >
        <Button
          content="Custom Size"
          selected={data.explosionChoice === 1}
          tooltip={multiline`
            Don't worry; pods are explosion-proof!
          `}
          onClick={() => act('explosionCustom')} />
        <Button
          content="Adminbus"
          selected={data.explosionChoice === 2}
          tooltip={multiline`
            Push buttons. What are they gonna do,
            ban you?
          `}
          onClick={() => act('explosionBus')} />
      </OptionLabel>
        <OptionLabel title="Damage on Landing" >
        <Button
          content="Custom Damage"
          selected={data.damageChoice === 1}
          tooltip={multiline`
            Deals brute to anyone under the pod when it lands.
            Sucks to be them!
          `}
          onClick={() => act('damageCustom')} />
        <Button
          content="Gib"
          selected={data.damageChoice === 2}
          tooltip={multiline`
            Also deals 5000 brute damage, just to be sure.
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('damageGib')} />
      </OptionLabel>
        <OptionLabel title="Misc. Dangerous" >
        <Button
          content="Projectile Cloud"
          selected={data.effectShrapnel}
          tooltip={multiline`
            This will create a cloud of shrapnel on landing, 
            of any projectile you'd like!
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('effectShrapnel')} />
        <Button
          content="Stun"
          selected={data.effectStun}
          tooltip={multiline`
            Launching a pod will stun mobs on the target turf 
            until the pod lands, ensuring a hit.
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('effectStun')} />
          <Button
          content="Delimb"
          selected={data.effectLimb}
          tooltip={multiline`
            Carbons caught under the pod will lose a limb,
            excluding their head.
          `}
          
          onClick={() => act('effectLimb')} />
        <Button
          content="Yeet Organs"
          selected={data.effectOrgans}
          tooltip={multiline`
            ;Help my organs don't feel good
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('effectOrgans')} />
      </OptionLabel>
      </Section>
    </Fragment>
  );
};

const NormalEffects = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      <Section fill>
        <OptionLabel title = "Pod Effects" >
        <Button
          content="Pod Stays"
          selected={data.effectBluespace}
          tooltip={multiline`
            Pod stays after landing.
          `}
          
          onClick={() => act('effectBluespace')} />
        <Button
          content="Stealth"
          selected={data.effectStealth}
          tooltip={multiline`
            No target when launching. Combos well with invisible pods.
            Sneak attack, go!
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('effectStealth')} />
        <Button
          content="Quiet"
          selected={data.effectQuiet}
          tooltip={multiline`
            Pod won't make any sounds, except for custom admin ones!
          `}
          
          onClick={() => act('effectQuiet')} />
        <Button
          content="Missile Mode"
          selected={data.effectMissile}
          tooltip={multiline`
            Doesn't send items. Deletes after landing. Combos well 
            with explosion effect and missile style!
          `}
          tooltipPosition="bottom-left"
          onClick={() => act('effectMissile')} />
        
         
      </OptionLabel>
    
        <OptionLabel title="Launch Effects">
        <Button
          content="Burst Launch"
          selected={data.effectBurst}
          tooltip={multiline`
            Launch 5 pods at once. Combos well with
            Missile Mode!
          `}
          onClick={() => act('effectBurst')} />  
        <Button
          content="Specific Target"
          selected={data.effectTarget}
          tooltip={multiline`
            Pod will launch on a specified atom.
            Works well with the Stun effect.
          `}
          onClick={() => act('effectTarget')} /> 
          <Button
          content="Any Descent Angle"
          selected={data.effectCircle}
          tooltip={multiline`
            Pod will come in from any angle. Ask goof
            why this feature exists, not me.
          `}
          onClick={() => act('effectCircle')} />
      <Button
              content="Alert Ghosts"
              selected={data.effectAnnounce}
              tooltip={multiline`
                Leave on to entertain bored ghosts.
              `}
              onClick={() => act('effectAnnounce')} />
              </OptionLabel>
      </Section>

    </Fragment>
  );
};

const ReverseMenu = (props, context) => {
  const { act, data } = useBackend(context);
  return ( 
    <Section 
    fill 
    height="100%"
    title="Reverse Mode"
    buttons={(
      <Button 
      icon={data.effectReverse === 1 ? "toggle-on" : "toggle-off"}
      selected={data.effectReverse}
      tooltip={multiline`
        Doesn't send items. Pod closes and drops 
        off any new items to dropoff turf 
        (or bay if none specified).
      `}
      onClick={() => act('effectReverse')} />
    )}>
      {(data.effectReverse === 1 ) && (
      <Flex direction="column" height="100%">
        <Flex.Item>
          <Button
            content="Dropoff Turf"
            selected={data.picking_dropoff_turf}
            disabled={!data.effectReverse}
            tooltip={multiline`
              Where reverse pods drop off any newly-acquired cargo.
              Use the seethrough style for extra fun.
            `}
            tooltipPosition="bottom-right"
            onClick={() => act('pickDropoffTurf')} />
          <Button
            inline
            icon="trash"
            disabled={!data.dropoff_turf}
            tooltip={multiline`
              Clears the custom dropoff location. Reverse pods will
              instead dropoff at the selected bay.
            `}
            tooltipPosition="bottom-right"
            onClick={() => act('clearDropoffTurf')} />
        </Flex.Item>
        <Divider horizontal />
        <Flex.Item>
          {REVERSE_OPTIONS.map((option, i) => (
              <Button
                inline
                icon="toggle-off"
                disabled={!data.effectReverse}
                content={option.title}
                onClick={() => act('clearDropoffTurf')} />
          ))}
        </Flex.Item>
      </Flex>)}
    </Section>
  );
};

const PresetsPage = (props, context) => {
  const { act, data } = useBackend(context);
  const [presetIndex, setPreset] = useLocalState(context, 'presetIndex', 0);
  return ( 
    <Section 
      fill 
      title="Presets" 
      
      buttons={(
        <Fragment>
          <Button
            inline
            color="transparent"
            icon="plus"
            />
            <Button
              inline
              color="transparent"
              content=""
              icon="download"
              />
              
            <Button
              inline
              color="transparent"
              content=""
              icon="upload"
              />
            <Button
            inline
            color="transparent"
            icon="trash"
            tooltip="bruh just do it"
            />
        </Fragment>)}>
      <Section  
      fill
      maxHeight="100px"
            overflowY="scroll"
            overflowX="hidden">

      
      <Tabs vertical>
        {PRESETS.map((page, i) => (
          <Tabs.Tab
            key={i}
            
            selected={i === presetIndex}
            onClick={() => setPreset(i)}
            content={page.title}
            >
          
          </Tabs.Tab>
        ))}
      </Tabs>
      </Section>
    </Section>

  );
};
const LaunchPage = (props, context) => {
  const { act, data } = useBackend(context);
  const [presetIndex, setPreset] = useLocalState(context, 'presetIndex', 0);
  return ( 
    <Section fill>
      <Button
      
       
        height="100%"
        width="100%"
        
        style={{'text-align': 'center'}}

        selected={data.giveLauncher}
        tooltip="THE CODEX ASTARTES CALLS THIS MANEUVER: STEEL RAIN"
        onClick={() => act('giveLauncher')} >
          <h1>
            <br/>
          LAUNCH
          </h1>
            
          
          </Button>

    </Section>

  );
};
const StylePage = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    text,
    setText,
  ] = useLocalState(context, 'text', "Sample text");
  return ( 
    <Section title="Pod Style" fill width="100%">
      <Section height="80px" maxWidth = "300px" overflowX="scroll" overflowY="hidden">
      <Flex>
        

        
      {STYLES.map((page, i) => (
        <Flex.Item>
        <Button width="50px" height="50px"
        
        
        style={{
          'vertical-align': 'middle',
          
          'margin-right':'5px',
         
          'border-radius':'5px',
          
        }} >
        <Box 
        className={classes(['supplypods64x64', 'pod_asset'+(i+1)])}
        style={{
          
          'transform': 'rotate(45deg) translate(-20%,-5%)'}} />
        </Button>

</Flex.Item>
    ))}

      </Flex>
      </Section>
      
    

    </Section>
  );
};
const Timing = (props, context) => {
  const { act, data } = useBackend(context);
  return ( 
    <Section title="Edit Timing" fill width="100%">
        <LabeledList>
{DELAYS.map((page, i) => (

    <LabeledList.Item label={page.title}>

    
 
      <Knob
        
       
        step={0.5}
        
        stepPixelSize={5}
        value={5}
        minValue={0}
        maxValue={10}
        onChange={(e, value) => setNumber(value)} />
     

          </LabeledList.Item>

))}

</LabeledList>


    </Section>
  );
};


const DelayKnob = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    title
  } = props;
  return ( 
    <Section
      inline
      mt={1}
      height="8vw"
      width="8vw"
      style={{ "text-align": "center" }}
      >
      <span>
        {title}
      </span>
      <br />
      <Knob
        inline
        size={1}
        step={1}

        stepPixelSize={2}
        value={data.landingDelay}
        minValue={-100}
        maxValue={100}
        onDrag={(e, value) => setNumber(value)} />
      <br />
      <span>
        {5}
      </span>
    </Section>
  );
};


const OptionLabel = props => {
  const {
    title,
    children,
  } = props;
  return ( 
    <Fragment>
      <span style={dropoff_grey}>
        <b>{title}</b>
      </span>
      <br />
      {children}
      <br />
      <br />
      </Fragment>
    
  );
};

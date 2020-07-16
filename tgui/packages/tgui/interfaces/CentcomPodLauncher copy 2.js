import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Flex, ByondUi, Section, Tabs,Knob, Box, Button, Fragment, ProgressBar, NumberInput, Icon, Input, LabeledList } from '../components';
import { Window } from '../layouts';

const skillgreen = {
  color: '#FFE8F0'
};

export const CentcomPodLauncher = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
    title="Config/Launch Supply Pod"
    width={800}
    height={434}
    resizable
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
      <CentcomPodLauncherContent />
    </Window>
  );
};

const CentcomPodLauncherContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [pageIndex, setPageIndex] = useLocalState(context, 'pageIndex', 0);
  const [tabPageIndex, setTabPageIndex] = useLocalState(context, 'tabPageIndex', 1);

  const PageComponent = PAGES[pageIndex].component();
  const TabPageComponent = TABPAGES[tabPageIndex].component();
  const marginer = 0.5
  return (
    <Window.Content scrollable>
			<Flex height="100%">
				<Flex.Item width="30%">
					<Flex direction="column" height="100%" >
						<Flex.Item  grow={1} m={marginer}>
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
						</Flex.Item>
						<Flex.Item grow={1}  m={marginer}>
							<QuickTeleport />
						</Flex.Item>
						<Flex.Item grow={1} m={marginer}>
							<Timing />
						</Flex.Item>
					</Flex>
    		</Flex.Item>

				<Flex.Item width="30%" >    
					<Flex direction="column" height="100%">
						<Flex.Item grow={1} m={marginer} >
							<PageComponent />
						</Flex.Item>
						<Flex.Item maxHeight="150px" m={marginer} >
							<PresetsPage />
						</Flex.Item>
					</Flex>
				</Flex.Item>

        <Flex.Item grow={1}>
					<Flex direction="column"  height="100%">
            <Flex.Item grow={1} m={marginer}>
            <Section title="View" fill buttons={(
            <Fragment>
                  <Button
                    inline
                    color="transparent"
                    content="Pod"
                    icon="rocket"
                    selected={0 === tabPageIndex}
                    onClick={() => {
                      setTabPageIndex(0);
                      act('tabSwitch', {tabIndex: 0});
                      }}/>
                    
                  <Button
                    inline
                    color="transparent"
                    content="Bay"
                    icon="th"
                    selected={1 === tabPageIndex}
                    onClick={() => {
                      setTabPageIndex(1);
                      act('tabSwitch', {tabIndex: 1});
                      }}/>
                    
                </Fragment>
                )}>
              <TabPageComponent />
              </Section>
            </Flex.Item>

						<Flex.Item m={marginer}>
							<LaunchPage />
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
    title: 'Harmful Effects',
    component: () => HarmfulEffects,
  },
  {
    title: 'Other Effects',
    component: () => OtherEffects,
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
    title: 'Fall Duration',
    component: () => HarmfulEffects,
  },
  {
    title: 'Opening Delay',
    component: () => OtherEffects,
  },
  {
    title: 'Leaving Delay',
    component: () => LoadingMethod,
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

const TabBay = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef } = data;
  return (
    
      <ByondUi
        fillPositionedParent
        params={{
          zoom: 0,
          id: mapRef,
          parent: config.window.id,
          type: 'map',
        }} />

   
  );
};

const TabPod = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef } = data;
  return (
    
      <ByondUi        
        fillPositionedParent
        params={{
          zoom: 0,
          id: mapRef,
          parent: config.window.id,
          type: 'map',
        }} />


  );
};


const LoadingMethod = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>

      
      <Section title="Pod Loading"
        fill
        overflow-y="scroll">
        <span style={skillgreen}>
          <b>Source Area</b>
          <br />

        </span>
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

 
        <OptionLabel title="Turf Selection Method" />
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

        <OptionLabel title="Item Loading Method" />
        <Button
          content="Clone Items"
          selected={data.launchClone}
          tooltip={multiline`
            Choosing this will create a duplicate of the item to be
            launched in Centcom, allowing you to send one type of item
            multiple times. Either way, the atoms are forceMoved into
            the supplypod after it lands (but before it opens).
          `}
          onClick={() => act('launchClone')} />
        <Button
          content="Random Items"
          selected={data.launchRandomItem}
          tooltip={multiline`
            Choosing this will pick a random item from the selected turf
            instead of the entire turfs contents. Best combined with
            single/random turf.
          `}
          onClick={() => act('launchRandomItem')} />
      </Section>
    </Fragment>
  );
};

const HarmfulEffects = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      <Section>
        <OptionLabel title="Explosion on Landing" />
        <Button
          content="Custom Size"
          selected={data.explosionChoice === 1}
          tooltip={multiline`
            This will cause an explosion of whatever size you like
            (including flame range) to occur as soon as the supplypod
            lands. Dont worry, supply-pods are explosion-proof!
          `}
          onClick={() => act('explosionCustom')} />
        <Button
          content="Adminbus"
          selected={data.explosionChoice === 2}
          tooltip={multiline`
            This will cause a maxcap explosion (dependent on server
            config) to occur as soon as the supplypod lands. Dont worry,
            supply-pods are explosion-proof!
          `}
          onClick={() => act('explosionBus')} />
      </Section>
      <Section>
        <OptionLabel title="Damage on Landing" />
        <Button
          content="Custom Damage"
          selected={data.damageChoice === 1}
          tooltip={multiline`
            Anyone caught under the pod when it lands will be dealt
            this amount of brute damage. Sucks to be them!
          `}
          onClick={() => act('damageCustom')} />
        <Button
          content="Gib"
          selected={data.damageChoice === 2}
          tooltip={multiline`
            This will attempt to gib any mob caught under the pod when
            it lands, as well as dealing a nice 5000 brute damage. Ya
            know, just to be sure!
          `}
          onClick={() => act('damageGib')} />
      </Section>
      <Section>
        <OptionLabel title="Misc. Dangerous" />
        <Button
          content="Projectile Cloud"
          selected={data.effectShrapnel}
          tooltip={multiline`
            This will create a cloud of shrapnel on landing, 
            of any projectile you'd like!
          `}
          onClick={() => act('effectShrapnel')} />
        <Button
          content="Stun"
          selected={data.effectStun}
          tooltip={multiline`
            Anyone who is on the turf when the supplypod is launched
            will be stunned until the supplypod lands. They cant get
            away that easy!
          `}
          onClick={() => act('effectStun')} />
          <Button
          content="Delimb"
          selected={data.effectLimb}
          tooltip={multiline`
            This will cause anyone caught under the pod to lose a limb,
            excluding their head.
          `}
          onClick={() => act('effectLimb')} />
        <Button
          content="Yeet Organs"
          selected={data.effectOrgans}
          tooltip={multiline`
            This will cause anyone caught under the pod to lose all
            their limbs and organs in a spectacular fashion.
          `}
          onClick={() => act('effectOrgans')} />
      </Section>
    </Fragment>
  );
};

const OtherEffects = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Fragment>
      <Section>
        <OptionLabel title = "Pod Effects" />
        <Button
          content="Bluespace"
          selected={data.effectBluespace}
          tooltip={multiline`
            Gives the supplypod an advanced Bluespace Recyling Device.
            After opening, the supplypod will be warped directly to the
            surface of a nearby NT-designated trash planet (/r/ss13).
          `}
          onClick={() => act('effectBluespace')} />
        <Button
          content="Stealth"
          selected={data.effectStealth}
          tooltip={multiline`
            This hides the red target icon from appearing when you
            launch the supplypod. Combos well with the "Invisible"
            style. Sneak attack, go!
          `}
          onClick={() => act('effectStealth')} />
        <Button
          content="Quiet"
          selected={data.effectQuiet}
          tooltip={multiline`
            This will keep the supplypod from making any sounds, except
            for those specifically set by admins in the Sound section.
          `}
          onClick={() => act('effectQuiet')} />
        <Button
          content="Missile Mode"
          selected={data.effectMissile}
          tooltip={multiline`
            This pod will not send any items. Instead, it will immediately
            delete after landing (Similar visually to setting openDelay
            & departDelay to 0, but this looks nicer). Useful if you just
            wanna fuck some shit up. Combos well with the Missile style.
          `}
          onClick={() => act('effectMissile')} />
        <Button
          content="Any Descent Angle"
          selected={data.effectCircle}
          tooltip={multiline`
            This will make the supplypod come in from any angle. Im not
            sure why this feature exists, but here it is.
          `}
          onClick={() => act('effectCircle')} />
        <Button
          content="Burst Launch"
          selected={data.effectBurst}
          tooltip={multiline`
            This will make each click launch 5 supplypods inaccuratly
            around the target turf (a 3x3 area). Combos well with the
            Missile Mode if you dont want shit lying everywhere after.
          `}
          onClick={() => act('effectBurst')} />   
      </Section>
      <Section>
        <OptionLabel title="Special Effects"/>
        <Button
          content="Reverse Mode"
          selected={data.effectReverse}
          tooltip={multiline`
            This pod will not send any items. Instead, after landing,
            the supplypod will close (similar to a normal closet closing),
            and then launch back to the right centcom bay to drop off any
            new contents.
          `}
          onClick={() => act('effectReverse')} />
        <Button
          content="Specific Target"
          selected={data.effectTarget}
          tooltip={multiline`
            This will make the supplypod target a specific atom, instead
            of the mouses position. Works well with the Stun effect.
            Smiting does this automatically!
          `}
          onClick={() => act('effectTarget')} />
      </Section>

    </Fragment>
  );
};

const QuickTeleport = (props, context) => {
  const { act, data } = useBackend(context);
  return ( 
    <Section fill title="Quick Teleport">
      <Button
        content={data.bay}
        onClick={() => act('teleportCentcom')} />
      <Button
        content={data.oldArea ? data.oldArea : 'Where you were'}
        disabled={!data.oldArea}
        onClick={() => act('teleportBack')} />
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
      maxHeight="100%" 
      overflowY="scroll"
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

  );
};
const LaunchPage = (props, context) => {
  const { act, data } = useBackend(context);
  const [presetIndex, setPreset] = useLocalState(context, 'presetIndex', 0);
  return ( 
    <Section title="Launch" minHeight="100%" maxHeight="150px">
      Launch~!
      <br />

      Button
      <br />
      another button
    </Section>

  );
};

const Timing = (props, context) => {
  const { act, data } = useBackend(context);
  return ( 
    <Section title="Edit Timing" minHeight="100%">
      

      <LabeledList>

      {DELAYS.map((page, i) => (
        <LabeledList.Item label={page.title}>
            <NumberInput
              animated
              width="40px"
              step={1}
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
    title
  } = props;
  return ( 
    <span style={skillgreen}>
      <br />
      <br />
      <b>{title}</b>
      <br />

    </span>
  );
};

const loadingMethods = (props, context) => {
  const { act, data } = useBackend(context);
  return ( <Box>Hi</Box>
  );
};


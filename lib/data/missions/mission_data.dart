import 'package:three_js/three_js.dart' as three;
import '../../game/missions/mission.dart';
import '../../game/missions/mission_objective.dart';

/// Phase 45: Full 30-mission campaign database across all 5 acts of VAYAL.
class MissionData {
  // ══════════════════════════════════════════════════════════════════
  //  ACT I — HOME  (missions 01–06)
  // ══════════════════════════════════════════════════════════════════

  static Mission buildMission01() => Mission(
        id: 'mission_01_homecoming',
        title: 'HOMECOMING',
        description:
            'Aadithyan "Aadi" Menon arrives in Veyrapuram after years away. Return to the family house.',
        status: MissionStatus.active,
        nextMissionId: 'mission_02_new_start',
        reward: const MissionReward(
          money: 500,
          reputation: 15,
          storyFlags: {
            'completed_mission_01': true,
            'homecoming_checkpoint': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_crossroad',
            description: 'Follow the residential street to the town crossroad',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(0.0, 0.0, 0.0),
            locationTolerance: 5.5,
          ),
          MissionObjective(
            id: 'obj_reach_house',
            description: "Go to Aadi's family house on the west road",
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-14.0, 0.0, -10.0),
            locationTolerance: 4.5,
          ),
          MissionObjective(
            id: 'obj_talk_meera',
            description: 'Speak with Meera on the house veranda',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'meera',
          ),
          MissionObjective(
            id: 'obj_enter_house',
            description: 'Enter the house through the front door',
            type: ObjectiveType.enterBuilding,
            targetObjectId: 'aadi_house_door',
          ),
        ],
      );

  static Mission buildMission02() => Mission(
        id: 'mission_02_new_start',
        title: 'A NEW START',
        description:
            'Try to leave the crime life behind. Find a normal job in Veyrapuram to support the family.',
        status: MissionStatus.available,
        nextMissionId: 'mission_03_diya_distance',
        reward: const MissionReward(
          money: 800,
          reputation: 20,
          storyFlags: {'completed_mission_02': true, 'reveal_aadis_old_gang': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_find_job_balan',
            description: "Inquire for work at Balan's chai stall in the village market",
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'balan',
          ),
        ],
      );

  static Mission buildMission03() => Mission(
        id: 'mission_03_diya_distance',
        title: "DIYA'S DISTANCE",
        description:
            "Diya hasn't said a word to Aadi since he arrived. Seek her out at the river bank.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_04_letter_from_nowhere',
        reward: const MissionReward(
          money: 300,
          reputation: 10,
          storyFlags: {'completed_mission_03': true, 'diya_first_talk': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_river',
            description: 'Walk to the river bank east of the village market',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(18.0, 0.0, -8.0),
            locationTolerance: 5.0,
          ),
          MissionObjective(
            id: 'obj_talk_diya',
            description: 'Talk to Diya by the river',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'diya',
          ),
        ],
      );

  static Mission buildMission04() => Mission(
        id: 'mission_04_letter_from_nowhere',
        title: 'LETTER FROM NOWHERE',
        description:
            'An unsigned letter was slipped under the front door overnight. Investigate its origin.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_05_balan_warning',
        reward: const MissionReward(
          money: 400,
          reputation: 15,
          storyFlags: {'completed_mission_04': true, 'letter_received': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_read_letter',
            description: 'Pick up and read the letter from the front door mat',
            type: ObjectiveType.collectItem,
            targetObjectId: 'unsigned_letter',
          ),
          MissionObjective(
            id: 'obj_ask_meera_letter',
            description: 'Ask Meera if she saw who left it',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'meera',
          ),
        ],
      );

  static Mission buildMission05() => Mission(
        id: 'mission_05_balan_warning',
        title: "BALAN'S WARNING",
        description:
            "Balan pulls Aadi aside at the stall. Men from the Old Town are asking questions about him.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_06_old_town_recon',
        reward: const MissionReward(
          money: 600,
          reputation: 20,
          storyFlags: {'completed_mission_05': true, 'old_town_threat_known': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_meet_balan',
            description: "Return to Balan's stall in the village market",
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'balan',
          ),
        ],
      );

  static Mission buildMission06() => Mission(
        id: 'mission_06_old_town_recon',
        title: 'OLD TOWN RECON',
        description:
            'Scout the western Old Town bazaar without being identified by the syndicate watchers.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_07_shadows_on_porch',
        reward: const MissionReward(
          money: 1000,
          reputation: 25,
          storyFlags: {'completed_mission_06': true, 'old_town_scouted': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_old_town_gate',
            description: 'Enter Old Town through the stone arch without drawing attention',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-55.0, 0.0, 0.0),
            locationTolerance: 6.0,
          ),
          MissionObjective(
            id: 'obj_observe_watchers',
            description: 'Identify the syndicate watcher near the tea house',
            type: ObjectiveType.interactObject,
            targetObjectId: 'syndicate_watcher_post',
          ),
          MissionObjective(
            id: 'obj_leave_undetected',
            description: 'Exit Old Town without being confronted',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-30.0, 0.0, 0.0),
            locationTolerance: 5.0,
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════════
  //  ACT II — GHOSTS  (missions 07–12)
  // ══════════════════════════════════════════════════════════════════

  static Mission buildMission07() => Mission(
        id: 'mission_07_shadows_on_porch',
        title: 'SHADOWS ON THE PORCH',
        description:
            'A threat photograph arrived with an old gang photo. Question the informant in the bazaar.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_08_informant_deal',
        reward: const MissionReward(
          money: 1200,
          reputation: 25,
          storyFlags: {
            'completed_mission_07': true,
            'informant_questioned': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_old_town',
            description: 'Travel west through the stone arch into Old Town Bazaar',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-62.0, 0.0, 0.0),
            locationTolerance: 8.0,
          ),
          MissionObjective(
            id: 'obj_question_informant',
            description: 'Find and confront the Hooded Informant in the market alley',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'informant',
          ),
        ],
      );

  static Mission buildMission08() => Mission(
        id: 'mission_08_informant_deal',
        title: 'THE INFORMANT\'S PRICE',
        description:
            'The informant will only talk if Aadi brings him a specific item from the pawn shop.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_09_photograph_truth',
        reward: const MissionReward(
          money: 900,
          reputation: 20,
          storyFlags: {'completed_mission_08': true, 'informant_bribed': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_find_pawn_shop',
            description: 'Locate the pawn shop on the eastern bazaar lane',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-70.0, 0.0, 8.0),
            locationTolerance: 4.0,
          ),
          MissionObjective(
            id: 'obj_buy_item',
            description: 'Purchase the brass compass the informant specified',
            type: ObjectiveType.collectItem,
            targetObjectId: 'brass_compass',
          ),
          MissionObjective(
            id: 'obj_return_informant',
            description: 'Return the compass to the informant',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'informant',
          ),
        ],
      );

  static Mission buildMission09() => Mission(
        id: 'mission_09_photograph_truth',
        title: 'WHAT THE PHOTOGRAPH SAYS',
        description:
            'The informant reveals the photograph was sent as a warning — by someone inside the family circle.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_10_night_market',
        reward: const MissionReward(
          money: 1500,
          reputation: 30,
          storyFlags: {
            'completed_mission_09': true,
            'reveal_rahus_disappearance': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_listen_informant',
            description: 'Listen to the full account from the informant',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'informant',
          ),
          MissionObjective(
            id: 'obj_call_diya',
            description: "Warn Diya to stay inside using the phone",
            type: ObjectiveType.interactObject,
            targetObjectId: 'phone_call_diya',
          ),
        ],
      );

  static Mission buildMission10() => Mission(
        id: 'mission_10_night_market',
        title: 'NIGHT MARKET CONTACT',
        description:
            'A second informant leaves a note — meet them at the night market stall at 22:00.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_11_chase_the_runner',
        reward: const MissionReward(
          money: 1100,
          reputation: 20,
          storyFlags: {'completed_mission_10': true, 'second_informant_met': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_wait_for_night',
            description: 'Wait until 22:00 game time at the village square',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-5.0, 0.0, 5.0),
            locationTolerance: 6.0,
          ),
          MissionObjective(
            id: 'obj_reach_night_stall',
            description: 'Go to the kerosene-lit stall in the south bazaar lane',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-65.0, 0.0, -12.0),
            locationTolerance: 4.0,
          ),
          MissionObjective(
            id: 'obj_talk_night_contact',
            description: 'Talk to the contact before they leave',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'night_contact',
          ),
        ],
      );

  static Mission buildMission11() => Mission(
        id: 'mission_11_chase_the_runner',
        title: 'CHASE THE RUNNER',
        description:
            'The contact panics and flees when syndicate men appear. Chase him before he is caught.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_12_the_shipping_ledger',
        reward: const MissionReward(
          money: 1400,
          reputation: 30,
          storyFlags: {'completed_mission_11': true, 'runner_saved': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_chase_runner',
            description: 'Chase the contact through the winding bazaar lanes',
            type: ObjectiveType.followNpc,
            targetNpcId: 'night_contact',
          ),
          MissionObjective(
            id: 'obj_escape_watchers',
            description: 'Escape the syndicate watchers without combat',
            type: ObjectiveType.escapeArea,
            targetLocation: three.Vector3(-80.0, 0.0, 0.0),
            locationTolerance: 8.0,
          ),
        ],
      );

  static Mission buildMission12() => Mission(
        id: 'mission_12_the_shipping_ledger',
        title: 'THE SHIPPING LEDGER',
        description:
            'The runner reveals the ledger location inside the Industrial Depot. Recover it.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_13_cold_trail_berth4',
        reward: const MissionReward(
          money: 1800,
          reputation: 35,
          storyFlags: {
            'completed_mission_12': true,
            'has_shipping_ledger': true,
            'reveal_fathers_suspicious_death': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_industrial',
            description: 'Drive east into the Devraj Enterprises Industrial District',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(62.0, 0.0, 0.0),
            locationTolerance: 8.0,
          ),
          MissionObjective(
            id: 'obj_recover_ledger',
            description: 'Secure the Shipping Ledger from the depot storage office',
            type: ObjectiveType.collectItem,
            targetObjectId: 'shipping_ledger',
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════════
  //  ACT III — BLOOD  (missions 13–18)
  // ══════════════════════════════════════════════════════════════════

  static Mission buildMission13() => Mission(
        id: 'mission_13_cold_trail_berth4',
        title: 'THE COLD TRAIL AT BERTH 4',
        description:
            "The informant confirmed Ravi Menon died uncovering contraband. Infiltrate the docks.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_14_the_second_ledger',
        reward: const MissionReward(
          money: 2000,
          reputation: 35,
          storyFlags: {'completed_mission_13': true, 'berth4_first_visit': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_harbour_gate',
            description: 'Get to the harbour perimeter fence without triggering alarms',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(5.0, 0.0, -185.0),
            locationTolerance: 8.0,
          ),
          MissionObjective(
            id: 'obj_find_berth4_entrance',
            description: "Locate Berth 4's restricted access gate",
            type: ObjectiveType.interactObject,
            targetObjectId: 'berth4_gate',
          ),
        ],
      );

  static Mission buildMission14() => Mission(
        id: 'mission_14_the_second_ledger',
        title: 'THE SECOND LEDGER',
        description:
            'A second page hidden inside the dock office holds Devraj\'s handwritten authorisation.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_15_escape_the_docks',
        reward: const MissionReward(
          money: 2200,
          reputation: 40,
          storyFlags: {
            'completed_mission_14': true,
            'father_truth_found': true,
            'reveal_devrajs_involvement': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_enter_dock_office',
            description: 'Enter the dock office through the back window',
            type: ObjectiveType.enterBuilding,
            targetObjectId: 'dock_office_back_window',
          ),
          MissionObjective(
            id: 'obj_find_second_ledger',
            description: 'Search the filing cabinet for the second ledger page',
            type: ObjectiveType.collectItem,
            targetObjectId: 'second_ledger_page',
          ),
        ],
      );

  static Mission buildMission15() => Mission(
        id: 'mission_15_escape_the_docks',
        title: 'ESCAPE THE DOCKS',
        description:
            "Guards have spotted Aadi. Get out of Berth 4 before the alarm locks down the harbour.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_16_rahu_ultimatum',
        reward: const MissionReward(
          money: 1600,
          reputation: 30,
          storyFlags: {
            'completed_mission_15': true,
            'berth4_infiltrated': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_evade_guards',
            description: 'Evade the harbour security guards',
            type: ObjectiveType.escapeArea,
            targetLocation: three.Vector3(10.0, 0.0, -170.0),
            locationTolerance: 8.0,
          ),
          MissionObjective(
            id: 'obj_reach_highway_safe',
            description: 'Reach the safety of the Coastal Highway corridor',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(0.0, 0.0, -145.0),
            locationTolerance: 10.0,
          ),
        ],
      );

  static Mission buildMission16() => Mission(
        id: 'mission_16_rahu_ultimatum',
        title: "RAHU'S ULTIMATUM",
        description:
            'Rahu has returned to Veyrapuram with a dangerous proposition. Meet him on the Coastal Highway.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_17_highway_deal',
        reward: const MissionReward(
          money: 2500,
          reputation: 35,
          storyFlags: {
            'completed_mission_16': true,
            'met_rahu': true,
            'reveal_betrayal_of_rahu': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_highway',
            description: 'Drive south onto the elevated Coastal Highway Corridor',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(0.0, 0.0, -140.0),
            locationTolerance: 10.0,
          ),
          MissionObjective(
            id: 'obj_talk_rahu',
            description: "Confront Rahu about Devraj's betrayal",
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'rahu',
          ),
        ],
      );

  static Mission buildMission17() => Mission(
        id: 'mission_17_highway_deal',
        title: 'THE DEAL ON THE HIGHWAY',
        description:
            "Rahu offers a way into Devraj's inner circle — but wants Aadi to do something illegal first.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_18_the_burner_phone',
        reward: const MissionReward(
          money: 2800,
          reputation: 30,
          storyFlags: {'completed_mission_17': true, 'rahu_deal_offered': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_listen_rahu_plan',
            description: "Hear Rahu's full proposition without walking away",
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'rahu',
          ),
          MissionObjective(
            id: 'obj_make_decision',
            description: 'Choose whether to accept, stall, or reject',
            type: ObjectiveType.makeDecision,
            targetObjectId: 'rahu_deal_choice',
          ),
        ],
      );

  static Mission buildMission18() => Mission(
        id: 'mission_18_the_burner_phone',
        title: 'THE BURNER PHONE',
        description:
            "Rahu's intel leads to a burner phone hidden near the harbour fence. Recover it.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_19_the_video',
        reward: const MissionReward(
          money: 2000,
          reputation: 25,
          storyFlags: {'completed_mission_18': true, 'burner_phone_found': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_fence_cache',
            description: 'Navigate to the harbour fence cache location at night',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(8.0, 0.0, -178.0),
            locationTolerance: 4.0,
          ),
          MissionObjective(
            id: 'obj_collect_phone',
            description: 'Retrieve the burner phone from its hiding spot',
            type: ObjectiveType.collectItem,
            targetObjectId: 'burner_phone',
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════════
  //  ACT IV — THE TRUTH  (missions 19–24)
  // ══════════════════════════════════════════════════════════════════

  static Mission buildMission19() => Mission(
        id: 'mission_19_the_video',
        title: 'THE VIDEO',
        description:
            'The burner phone contains a 43-second video from the night of the murder. Watch it.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_20_raghavi_trail',
        reward: const MissionReward(
          money: 1500,
          reputation: 40,
          storyFlags: {
            'completed_mission_19': true,
            'truth_video_discovered': true,
            'reveal_old_video': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_access_phone',
            description: "Open the burner phone's video archive",
            type: ObjectiveType.interactObject,
            targetObjectId: 'burner_phone',
          ),
          MissionObjective(
            id: 'obj_watch_video',
            description: 'Watch the full video recording from Berth 4',
            type: ObjectiveType.interactObject,
            targetObjectId: 'berth4_video_file',
          ),
        ],
      );

  static Mission buildMission20() => Mission(
        id: 'mission_20_raghavi_trail',
        title: "INSPECTOR RAGHAVI'S TRAIL",
        description:
            "The video shows a police officer at the scene. Find evidence linking Inspector Raghavi to Devraj.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_21_the_third_figure',
        reward: const MissionReward(
          money: 3000,
          reputation: 40,
          storyFlags: {
            'completed_mission_20': true,
            'raghavi_suspect': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_police_station',
            description: "Approach Veyrapuram police station without triggering Raghavi's attention",
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(30.0, 0.0, 20.0),
            locationTolerance: 6.0,
          ),
          MissionObjective(
            id: 'obj_collect_raghavi_schedule',
            description: "Copy Raghavi's patrol schedule from the station noticeboard",
            type: ObjectiveType.interactObject,
            targetObjectId: 'patrol_schedule_board',
          ),
        ],
      );

  static Mission buildMission21() => Mission(
        id: 'mission_21_the_third_figure',
        title: 'THE THIRD FIGURE',
        description:
            'Enhance the video frame by frame at the cyber café to identify the third person.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_22_safe_house',
        reward: const MissionReward(
          money: 2500,
          reputation: 45,
          storyFlags: {
            'completed_mission_21': true,
            'reveal_hidden_person_video': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_cyber_cafe',
            description: 'Find the cyber café near the town centre',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(8.0, 0.0, 14.0),
            locationTolerance: 4.0,
          ),
          MissionObjective(
            id: 'obj_enhance_video',
            description: 'Use the enhancement software to identify the third figure',
            type: ObjectiveType.interactObject,
            targetObjectId: 'cyber_cafe_terminal',
          ),
        ],
      );

  static Mission buildMission22() => Mission(
        id: 'mission_22_safe_house',
        title: 'PROTECT THE FAMILY',
        description:
            "Devraj's men have been seen near the Menon house. Move Meera and Diya to a safe location.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_23_raghavi_confrontation',
        reward: const MissionReward(
          money: 1800,
          reputation: 35,
          storyFlags: {'completed_mission_22': true, 'family_safe': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_warn_meera',
            description: 'Return home and warn Meera about the danger',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'meera',
          ),
          MissionObjective(
            id: 'obj_escort_family',
            description: "Drive Meera and Diya to Balan's safe house",
            type: ObjectiveType.driveToLocation,
            targetLocation: three.Vector3(-20.0, 0.0, 15.0),
            locationTolerance: 5.0,
          ),
        ],
      );

  static Mission buildMission23() => Mission(
        id: 'mission_23_raghavi_confrontation',
        title: 'FACE THE INSPECTOR',
        description:
            "Confront Inspector Raghavi with the video evidence. She must choose a side.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_24_imran_help',
        reward: const MissionReward(
          money: 3500,
          reputation: 45,
          storyFlags: {
            'completed_mission_23': true,
            'raghavi_confronted': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_arrange_meeting',
            description: "Leave a message at Raghavi's patrol checkpoint",
            type: ObjectiveType.interactObject,
            targetObjectId: 'raghavi_checkpoint_box',
          ),
          MissionObjective(
            id: 'obj_meet_raghavi',
            description: 'Meet Inspector Raghavi at the agreed-upon bridge',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'raghavi',
          ),
        ],
      );

  static Mission buildMission24() => Mission(
        id: 'mission_24_imran_help',
        title: "IMRAN'S NETWORK",
        description:
            "Aadi's former contact Imran can provide access to Devraj's facility schematics — for a price.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_25_velu_interrogation',
        reward: const MissionReward(
          money: 3200,
          reputation: 40,
          storyFlags: {
            'completed_mission_24': true,
            'helped_imran': true,
            'harbour_schematics_obtained': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_find_imran',
            description: 'Locate Imran at his hardware shop near the industrial district',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'imran',
          ),
          MissionObjective(
            id: 'obj_complete_imran_favour',
            description: "Complete Imran's favour: recover his brother's stolen goods",
            type: ObjectiveType.collectItem,
            targetObjectId: 'stolen_goods_crate',
          ),
          MissionObjective(
            id: 'obj_receive_schematics',
            description: 'Receive the Berth 4 schematics from Imran',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'imran',
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════════
  //  ACT V — VAYAL  (missions 25–30)
  // ══════════════════════════════════════════════════════════════════

  static Mission buildMission25() => Mission(
        id: 'mission_25_velu_interrogation',
        title: "VELU'S SECRET",
        description:
            "Devraj's enforcer Velu knows the loading schedule and patrol routes. Intercept and interrogate him.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_26_evidence_to_raghav',
        reward: const MissionReward(
          money: 4000,
          reputation: 50,
          storyFlags: {
            'completed_mission_25': true,
            'velu_confronted': true,
            'berth4_patrol_known': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_track_velu',
            description: "Track Velu's vehicle from the industrial district to his safe house",
            type: ObjectiveType.followNpc,
            targetNpcId: 'velu',
          ),
          MissionObjective(
            id: 'obj_intercept_velu',
            description: 'Corner Velu at his safe house before he can alert Devraj',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'velu',
          ),
        ],
      );

  static Mission buildMission26() => Mission(
        id: 'mission_26_evidence_to_raghav',
        title: 'HAND THE EVIDENCE',
        description:
            "Package the shipping ledger and video file. Hand them to Imran's journalist contact.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_27_final_preparation',
        reward: const MissionReward(
          money: 3500,
          reputation: 50,
          storyFlags: {
            'completed_mission_26': true,
            'evidence_handed_to_raghav': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_prepare_package',
            description: 'Combine the ledger pages and encrypted video into one package',
            type: ObjectiveType.interactObject,
            targetObjectId: 'evidence_package_table',
          ),
          MissionObjective(
            id: 'obj_deliver_evidence',
            description: "Meet Imran's contact at the bus station drop point",
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(-10.0, 0.0, 40.0),
            locationTolerance: 5.0,
          ),
        ],
      );

  static Mission buildMission27() => Mission(
        id: 'mission_27_final_preparation',
        title: 'FINAL PREPARATION',
        description:
            'The last hour before the infiltration. Gather weapons, plan the entry, and say goodbye.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_28_the_syndicate_falls',
        reward: const MissionReward(
          money: 2500,
          reputation: 40,
          storyFlags: {'completed_mission_27': true, 'final_prep_done': true},
        ),
        objectives: [
          MissionObjective(
            id: 'obj_visit_family',
            description: 'Say goodbye to Meera and Diya at the safe house',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'meera',
          ),
          MissionObjective(
            id: 'obj_equip_gear',
            description: 'Collect the equipment left by Rahu at the bridge cache',
            type: ObjectiveType.collectItem,
            targetObjectId: 'bridge_gear_cache',
            isOptional: false,
          ),
        ],
      );

  static Mission buildMission28() => Mission(
        id: 'mission_28_the_syndicate_falls',
        title: 'THE SYNDICATE FALLS',
        description:
            "Infiltrate the harbour and destroy Devraj's contraband infrastructure at Berth 4.",
        status: MissionStatus.locked,
        nextMissionId: 'mission_29_rahu_reckoning',
        reward: const MissionReward(
          money: 6000,
          reputation: 60,
          storyFlags: {
            'completed_mission_28': true,
            'syndicate_infrastructure_destroyed': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_breach_harbour',
            description: 'Breach the harbour perimeter using the stolen pass card',
            type: ObjectiveType.interactObject,
            targetObjectId: 'harbour_pass_card_reader',
          ),
          MissionObjective(
            id: 'obj_destroy_cargo',
            description: 'Destroy the three contraband containers at Berth 4',
            type: ObjectiveType.interactObject,
            targetObjectId: 'contraband_containers',
          ),
          MissionObjective(
            id: 'obj_set_timer',
            description: 'Plant the timer device on the main crane control box',
            type: ObjectiveType.collectItem,
            targetObjectId: 'crane_control_box',
          ),
        ],
      );

  static Mission buildMission29() => Mission(
        id: 'mission_29_rahu_reckoning',
        title: "RAHU'S RECKONING",
        description:
            'Rahu appears at Berth 4 — not as an enemy, but begging for absolution. What Aadi decides shapes the ending.',
        status: MissionStatus.locked,
        nextMissionId: 'mission_30_vayal_reckoning',
        reward: const MissionReward(
          money: 4500,
          reputation: 55,
          storyFlags: {
            'completed_mission_29': true,
            'rahu_final_decision_made': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_confront_rahu_berth',
            description: "Find Rahu on the Berth 4 loading platform",
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'rahu',
          ),
          MissionObjective(
            id: 'obj_decide_rahu_fate',
            description: "Decide Rahu's fate: spare him or leave him to face justice",
            type: ObjectiveType.makeDecision,
            targetObjectId: 'rahu_fate_choice',
          ),
        ],
      );

  static Mission buildMission30() => Mission(
        id: 'mission_30_vayal_reckoning',
        title: 'VAYAL — THE RECKONING',
        description:
            "Devraj stands at the far end of Berth 4. The truth is out. This is the last confrontation.",
        status: MissionStatus.locked,
        reward: const MissionReward(
          money: 10000,
          reputation: 100,
          storyFlags: {
            'completed_mission_30': true,
            'devraj_confronted': true,
            'game_climax_reached': true,
            'reveal_real_truth': true,
          },
        ),
        objectives: [
          MissionObjective(
            id: 'obj_reach_berth4_end',
            description: 'Reach the far end of Berth 4 where Devraj waits',
            type: ObjectiveType.reachLocation,
            targetLocation: three.Vector3(0.0, 0.0, -215.0),
            locationTolerance: 6.0,
          ),
          MissionObjective(
            id: 'obj_confront_devraj',
            description: 'Confront Devraj and end his control over Veyrapuram',
            type: ObjectiveType.talkToNpc,
            targetNpcId: 'devraj',
          ),
          MissionObjective(
            id: 'obj_final_choice',
            description: "Make the final choice that determines Aadi's fate",
            type: ObjectiveType.makeDecision,
            targetObjectId: 'final_ending_choice',
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════════
  //  Registry
  // ══════════════════════════════════════════════════════════════════

  /// Returns all 30 story missions keyed by ID.
  static Map<String, Mission> getAllMissions() {
    return {
      // Act I — Home
      'mission_01_homecoming': buildMission01(),
      'mission_02_new_start': buildMission02(),
      'mission_03_diya_distance': buildMission03(),
      'mission_04_letter_from_nowhere': buildMission04(),
      'mission_05_balan_warning': buildMission05(),
      'mission_06_old_town_recon': buildMission06(),
      // Act II — Ghosts
      'mission_07_shadows_on_porch': buildMission07(),
      'mission_08_informant_deal': buildMission08(),
      'mission_09_photograph_truth': buildMission09(),
      'mission_10_night_market': buildMission10(),
      'mission_11_chase_the_runner': buildMission11(),
      'mission_12_the_shipping_ledger': buildMission12(),
      // Act III — Blood
      'mission_13_cold_trail_berth4': buildMission13(),
      'mission_14_the_second_ledger': buildMission14(),
      'mission_15_escape_the_docks': buildMission15(),
      'mission_16_rahu_ultimatum': buildMission16(),
      'mission_17_highway_deal': buildMission17(),
      'mission_18_the_burner_phone': buildMission18(),
      // Act IV — The Truth
      'mission_19_the_video': buildMission19(),
      'mission_20_raghavi_trail': buildMission20(),
      'mission_21_the_third_figure': buildMission21(),
      'mission_22_safe_house': buildMission22(),
      'mission_23_raghavi_confrontation': buildMission23(),
      'mission_24_imran_help': buildMission24(),
      // Act V — Vayal
      'mission_25_velu_interrogation': buildMission25(),
      'mission_26_evidence_to_raghav': buildMission26(),
      'mission_27_final_preparation': buildMission27(),
      'mission_28_the_syndicate_falls': buildMission28(),
      'mission_29_rahu_reckoning': buildMission29(),
      'mission_30_vayal_reckoning': buildMission30(),
    };
  }
}

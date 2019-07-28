App = {
    contracts: {},

    load: async () => {
        await App.loadWeb3();
        await App.loadAccount();
        await App.loadContract();
        await App.render();
    },

    // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
    loadWeb3: async () => {
        if (typeof web3 !== 'undefined') {
        App.web3Provider = web3.currentProvider
        web3 = new Web3(web3.currentProvider)
        } else {
        window.alert("Please connect to Metamask.")
        }
        // Modern dapp browsers...
        if (window.ethereum) {
        window.web3 = new Web3(ethereum)
        try {
            // Request account access if needed
            await ethereum.enable()
            // Acccounts now exposed
            web3.eth.sendTransaction({/* ... */})
        } catch (error) {
            // User denied account access...
        }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
        App.web3Provider = web3.currentProvider
        window.web3 = new Web3(web3.currentProvider)
        // Acccounts always exposed
        web3.eth.sendTransaction({/* ... */})
        }
        // Non-dapp browsers...
        else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    },

    loadAccount: async () => {
        // Set the current blockchain account
        App.account = web3.eth.accounts[0];
    }, 

    loadContract: async () => {
        // Create a JavaScript version of the smart contracts
        const EHS = await $.getJSON('ElectronicHealthSystem.json');
        App.contracts.ElectronicHealthSystem = TruffleContract(EHS);
        App.contracts.ElectronicHealthSystem.setProvider(App.web3Provider);

        const Prv = await $.getJSON('Provider.json');
        App.contracts.Provider = TruffleContract(Prv);
        App.contracts.Provider.setProvider(App.web3Provider);

        // const patientC = await $.getJSON('Patient.json');
        // App.contracts.Patient = TruffleContract(patientC);
        // App.contracts.Patient.setProvider(App.web3Provider);

        // const providerC = await $.getJSON('Provider.json');
        // App.contracts.Provider = TruffleContract(providerC);
        // App.contracts.Provider.setProvider(App.web3Provider);

        // Hydrate the smart contract with values from the blockchain
        App.EHS = await App.contracts.ElectronicHealthSystem.deployed();
        App.Prv = await App.contracts.Provider.deployed();
        // App.patientC = await App.contracts.Patient.deployed();
        // App.providerC = await App.contracts.Provider.deployed();
    },

    render: async () => {
        // Prevent double rendering
        // if(App.loading) {
        //     return
        // }

        // // Update app loading state
        // App.setLoading(true);

        // Render Account
        $('#account').html(App.account);

        // // Render tasks
        // await App.renderTasks();

        // // Update app loading state
        // App.setLoading(false);

    },

    registerPatient: async () => {
        const fname = $('#fName').val();
        const lname = $('#lName').val();
        const dob = $('#dob').val();
        const address = $('#address').val();
        await App.EHS.registerAsPatient(fname, lname, dob, address);
    },

    registerProvider: async () => {
        await App.EHS.registerAsProvider();
    },

    addPatientByProvider: async() => {
        const patientAddress = $('#pat-address').val();
        await App.Prv.addPatient(patientAddress);
    }

    // renderTasks: async () => {
    //     // Load the total task count from the blockchain
    //     const taskCount = await App.todoList.taskCount();
    //     const $taskTemplate = $('.taskTemplate');

    //     // Render out each task with a new task template
    //     for (var i = 1; i <=taskCount; i++) {
    //         // fetch the task data from the blockchain
    //         const task = await App.todoList.tasks(i);
    //         const taskId = task[0].toNumber();
    //         const taskContent = task[1];
    //         const taskCompleted = task[2];

    //         // Create the html for the task
    //         const $newTaskTemplate = $taskTemplate.clone();
    //         $newTaskTemplate.find('.content').html(taskContent);
    //         $newTaskTemplate.find('input')
    //                         .prop('name', taskId)
    //                         .prop('checked', taskCompleted)
    //                         .on('click', App.toggleCompleted);

    //         // put the task in the correct list
    //         if (taskCompleted) {
    //             $('#completedTaskList').append($newTaskTemplate);
    //         } else {
    //             $('#taskList').append($newTaskTemplate);
    //         }
         
    //         // Show the task
    //         $newTaskTemplate.show();
    //     }
    // },

    // createTask: async () => {
    //     App.setLoading(true);
    //     const content = $('#newTask').val();
    //     await App.todoList.createTask(content);
    //     window.location.reload();
    // },

    // toggleCompleted: async (e) => {
    //     App.setLoading(true);
    //     const taskId = e.target.name;
    //     await App.todoList.toggleCompleted(taskId);
    //     window.location.reload();
    // },

    // setLoading: (boolean) => {
    //     App.loading = boolean
    //     const loader = $('#loader')
    //     const content = $('#content')
    //     if (boolean) {
    //       loader.show()
    //       content.hide()
    //     } else {
    //       loader.hide()
    //       content.show()
    //     }
    //   }

}

$(() => {
    $(window).load(() => {
        App.load();
    })
})